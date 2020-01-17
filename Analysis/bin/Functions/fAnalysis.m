function I_mean = fAnalysis(Data, Results, Config)
% Function to align the microtubules on the minus ends and calculate the
% mean intensity profiles

% Check input
if nargin < 3
    width = 3;
    interp = 5; % 5 times spline interpolation
else
    width = Config.width;
    interp = Config.interp;
end

if isempty(find(Results.Bin == 0))
    U = length(unique(Results.Bin(:,2)));
else
    U = length(unique(Results.Bin(:,1)))-1;
end
% I_mean = cell(U,1);
I_mean = [];
Mean_length = zeros(U, 1);
entry = 0;

norm = zeros(size(Data,1),1);
bkg_width = 3;
% Calculate mean dynein background signal
for n = 1 : size(Data,1)
   
    norm(n) = mean(mean(Data{n,4}(1:bkg_width,:)) + mean(Data{n,4}(end-bkg_width:end,:)))/2;
    
end
norm = mean(norm);


h = waitbar(0,'Aligning dataset...');

for n = 1 : U
    
    Profile_Dynein = [];
    
    % Find indeces of microtubules in bin 'n'
    ind = find(Results.Bin(:,1) == n);
    Mean_length(n) = mean(Results.Bin(ind,2));
    
    for m = 1 : length(ind)
        
        % Obtain size of the image
        [row, col] = size(Data{ind(m),4});
        
        Position = (1:1:col);
        Position_interp = (1:(1/interp):col);
        Shift = Results.MTend(ind(m),2);
        
        % Align on microtubule end
        Position = Position - Shift;
        Position_interp = Position_interp - Shift;      
        
        % Calculate the mean intensity profiles
        c = ceil(row/2);
        I_Dynein = mean(Data{ind(m),4}(c-width:c+width,:));
        
        % Interpolate data using a 'spline'
        I_Dynein_interp = interp1(Position, I_Dynein, Position_interp, 'spline');
        
%         plot(Position_interp, I_Dynein_interp, 'g', 'LineWidth', 2);

        Profile_Dynein = [Profile_Dynein; [Position_interp(:) I_Dynein_interp(:)]];       
        
    end
    
    if ~isempty(Profile_Dynein)
        % Sort positional data into bins           
        edges = -150:0.5:20;
        [N, edges, bin] = histcounts(Profile_Dynein(:,1), edges);

        entry = entry + 1;
        for i = 1 : length(edges)-1
            index = find(bin == i);            
            if ~isempty(index)
                I_mean{entry,1}(i,:) = [i N(i) mean(Profile_Dynein(index,1)) mean(Profile_Dynein(index,2)),...
                                    std(Profile_Dynein(index,2))/sqrt(N(i))];
            else
                I_mean{entry,1}(i,:) = [i N(i) NaN NaN NaN];
            end
        end
        
        % Calculate the mean MT length in the bin
        I_mean{entry,2} = Mean_length(n);  
        % Calculate the max intensity of the mean profile
        I_mean{entry,3} = max(I_mean{entry,1}(:,2));
               
        % Calculate the FWHM of the traffic jam with polyxpoly       
        I_half = max(I_mean{entry,1}(:,4)) - (max(I_mean{entry,1}(:,4))-norm)/2;
        
        x_line = [min(I_mean{entry,1}(:,3)) max(I_mean{entry,1}(:,3))];
        y_line = [1 1]*I_half;
        xData = I_mean{entry,1}(:,3);
        yData = I_mean{entry,1}(:,4);
        
        % Debugging:
%         hold on
%         plot(xData, yData);
%         plot(x_line, y_line);
%         hold off
        
        if max(I_mean{entry,1}(:,4))-min(I_mean{entry,1}(:,4)) < 100
            warning off
            % Fit dynein profile with a Gaussian function
            ft = fittype( 'I_a*exp(-((x-mu)^2)/(2*s^2))+C', 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Lower = [0 0 -10 -Inf];
            opts.Upper = [Inf Inf 10 Inf];
            opts.StartPoint = [norm max(I_mean{entry,1}(:,4))-norm -1 2];
            
            [xData_1, yData_1] = prepareCurveData( xData, yData );
            [fitresult, ~] = fit( xData_1, yData_1, ft, opts );
            I_mean{entry,4} = 2.355*fitresult.s;
            warning on
        else
            % Find intersecting points
            [xi, ~] = polyxpoly(xData, yData, x_line, y_line);      
            if length(xi) == 2
                I_mean{entry,4} = abs(diff(xi));
            else
                I_mean{entry,4} = NaN;
            end
        end
        
    end       
    waitbar(n/U,h);
end
close(h);

end


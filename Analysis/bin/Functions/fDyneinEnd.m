function [Data_new, LocationJam] = fDyneinEnd(Data, Config)

% Check input
if nargin < 2
    width = 3;
else
   width = Config.width; 
end

% Prepare output
LocationJam = [];
Data_new = Data;

% Number of seeds
nSeeds = size(Data,1);

% Fit the dynein intensity profile with a 'poly1' function. The slope
% should represent at which the traffic jam is located.

h = waitbar(0, 'Locating orientation traffic jams. Please wait...');

for n = 1 : nSeeds
    
    % Retrieve the dynein intensity profile
    I = Data{n,4};
    
    % Calculate mean profile in the centre with specified width
    [row,~] = size(I);
    c = ceil(row/2);
    I_mean = mean(I(c-width:c+width,:));
    
    % Fit the dynein intensity profile to a 'poly1' function
    [xData, yData] = prepareCurveData( [], I_mean );
    % Set up fittype and options.
    ft = fittype( 'poly1' );
    % Fit model to data.
    fitresult = fit( xData, yData, ft );
  
    LocationJam(n,1) = fitresult.p1;
    
    % Find position of maximum value    
    [I_max(1), I_max(2)] = max(I_mean);
    LocationJam(n,2) = I_max(2);
    
    % Determine whether the dynein traffic jam is on the left or right hand
    % side of the image.
    
    if LocationJam(n,1) > 0 && LocationJam(n,2) > size(I,2)/2 % right hand side
        LocationJam(n,3) = 1;
    elseif LocationJam(n,1) < 0 && LocationJam(n,2) < size(I,2)/2 % left hand side
        LocationJam(n,3) = -1;
        % Align the data with the minus end on the left
        Data_new{n,3} = fliplr(Data_new{n,3});
        Data_new{n,4} = fliplr(Data_new{n,4});
    else % inconclusive outcome
        LocationJam(n,3) = 0;        
    end        

    waitbar(n / nSeeds);
end
close(h)

end


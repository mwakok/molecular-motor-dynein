function [Output, FWHM] = fFitMT(Data, Config)

nSeeds = size(Data,1);  
% Create output container
Output = [];

% Check input
if nargin < 2
    width = 3;
else
    width = Config.width;
end



% Set up fittype and options.
ft_1 = fittype( 'I_bg+(1/2)*I_a*erfc((x-mu)/(sqrt(2)*s))', 'independent', 'x', 'dependent', 'y' );
ft_2 = fittype( 'I_a*exp(-((x-mu)^2)/(2*s^2))', 'independent', 'x', 'dependent', 'y' );
if Config.CPU == 1
    % Waitbar initialization
    parfor_progress(nSeeds);
    
    parfor n = 1 : nSeeds

        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        Pos = [];
        Sigma = [];
        gof = [];

        [row,~] = size(Data{n,3});

        c = ceil(row/2);

        I = mean(Data{n,3}(c-width:c+width,:));
        I_left = I(1:ceil(length(I)/2));
        I_right = I(ceil(length(I)/2):end);

        % Normalize the data 
        I_left = I_left ./ max(I_left);
        I_right = I_right ./ max(I_right);    

         % Fit microtubule end left
        [xData, yData] = prepareCurveData( [], I_left );

        opts.Lower = [0 0 0 -5];
        opts.StartPoint = [1 0 10 -2];
        opts.Upper = [Inf Inf Inf 5];

        % Fit model to data.
        [fitresult_left, gof_left] = fit( xData, yData, ft_1, opts );

        % Plot the fit result
    %     figure
    %     plot(fitresult_left, xData, yData);

        % Fit microtubule end right
        [xData, yData] = prepareCurveData( [], I_right );

        opts.Lower = [0 0 0 -5];
        opts.StartPoint = [1 0 length(I_right)-10 2];
        opts.Upper = [Inf Inf Inf 5];
        [fitresult_right, gof_right] = fit( xData, yData, ft_1, opts );

        % Plot the fit result
    %     figure
    %     plot(fitresult_right, xData, yData);

        % Obtain the fitted positions
        Pos = [fitresult_left.mu fitresult_right.mu+ceil(length(I)/2)];
        Sigma = [ fitresult_left.s  fitresult_right.s];
        gof = [gof_left.rsquare gof_right.rsquare];

        Output(n,:) = [Pos Sigma gof];
        
        % Obtain the normalized intensity across the microtubule
        I_width = nanmean(Data{n,3},2);
        I_width = I_width - min(I_width);
        I_width = I_width / max(I_width);
        
        % Fit the width with a Gaussian to determine the FWHM
        opts.Lower = [0 0 0];
        opts.StartPoint = [1 10 2];
        opts.Upper = [Inf Inf Inf];
        [xData, yData] = prepareCurveData( [], I_width );
        [fitresult_width, ~] = fit( xData, yData, ft_2, opts );
        
        FWHM(n,:) = 2.355*fitresult_width.s;
        
        parfor_progress;
    end
    parfor_progress(0);

elseif Config.CPU == 0
    % Waitbar initialization
    h =  waitbar(0,'Fitting microtubule ends, please wat...');
    
    for n = 1 : nSeeds
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        Pos = [];
        Sigma = [];
        gof = [];

        [row,~] = size(Data{n,3});

        c = ceil(row/2);

        I = mean(Data{n,3}(c-width:c+width,:));
        I_left = I(1:ceil(length(I)/2));
        I_right = I(ceil(length(I)/2):end);

        % Normalize the data 
        I_left = I_left ./ max(I_left);
        I_right = I_right ./ max(I_right);    

         % Fit microtubule end left
        [xData, yData] = prepareCurveData( [], I_left );

        opts.Lower = [0 0 0 -5];
        opts.StartPoint = [1 0 10 -2];
        opts.Upper = [Inf Inf Inf 5];

        % Fit model to data.
        [fitresult_left, gof_left] = fit( xData, yData, ft_1, opts );

        % Plot the fit result
    %     figure
    %     plot(fitresult_left, xData, yData);

        % Fit microtubule end right
        [xData, yData] = prepareCurveData( [], I_right );

        opts.Lower = [0 0 0 -5];
        opts.StartPoint = [1 0 length(I_right)-10 2];
        opts.Upper = [Inf Inf Inf 5];
        [fitresult_right, gof_right] = fit( xData, yData, ft_1, opts );

        % Plot the fit result
    %     figure
    %     plot(fitresult_right, xData, yData);

        % Obtain the fitted positions
        Pos = [fitresult_left.mu fitresult_right.mu+ceil(length(I)/2)];
        Sigma = [ fitresult_left.s  fitresult_right.s];
        gof = [gof_left.rsquare gof_right.rsquare];

        Output(n,:) = [Pos Sigma gof];

         % Obtain the normalized intensity across the microtubule
        I_width = nanmean(Data{n,3},2);
        I_width = I_width - min(I_width);
        I_width = I_width / max(I_width);
        
        % Fit the width with a Gaussian to determine the FWHM
        opts.Lower = [0 0 0];
        opts.StartPoint = [1 10 2];
        opts.Upper = [Inf Inf Inf];
        [xData, yData] = prepareCurveData( [], I_width );
        [fitresult_width, ~] = fit( xData, yData, ft_2, opts );
        
        FWHM(n,:) = 2.355*fitresult_width.s;
        
        waitbar(n/nSeeds, h);
    end
    close(h);
end

end
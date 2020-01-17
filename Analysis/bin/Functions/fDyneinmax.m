function fitresult = fDyneinmax(x, y)

[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a*(1-exp(-b*x))+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0];
opts.Upper = [Inf 1 Inf];
opts.StartPoint = [max(yData)-min(yData) 0.5 min(yData)];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );


end
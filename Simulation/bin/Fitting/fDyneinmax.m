function fitresult = fDyneinmax(x, y)

[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a*(1-exp(-b*x))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.196373870300458 0.100665997198004];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );


end
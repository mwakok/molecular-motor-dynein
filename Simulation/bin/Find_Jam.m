%% Plot data

um = (1:1:length(Data{1}))*0.024; 
[X,Y] = meshgrid(um, (1:1:min(A)));
for n = 1 : min(A)
   Z(n,:) = Data{n}; 
end

figure
hold on
surf(X,Y,Z);
set(gca, 'YDir', 'reverse');
view(0, 90);
xlabel('MT length (\mum)')
ylabel('Time (min)')
hold off

%% Find the edge of the traffic jam with the error function

for n = 1 : size(Z,1)
   
    XData = X(n,:);
    YData = Z(n,:);
    
    [xData, yData] = prepareCurveData( XData, YData );

    % Set up fittype and options.
    ft = fittype( 'b*erf((x-x0)/a)+C', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 0 0];
    opts.StartPoint = [0.959743958516081 0.741535186292404 0.00934075459301742 0.340385726666133];
    opts.Upper = [1 1 1 max(X(:))];
    
    % Fit model to data.
    [fitresult{n}, gof{n}] = fit( xData, yData, ft, opts );
    
    Pos(n) = fitresult{n}.x0;
    
end

%% Plot traffic jam

time = Y(:,1);

figure
hold on
plot(time, max(X(:)) - Pos);
xlabel('Time (min)')
ylabel('Traffic jam length (\mum)')
hold off

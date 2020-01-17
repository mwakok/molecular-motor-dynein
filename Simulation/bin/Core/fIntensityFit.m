function fIntensityFit(Output)

%% Load data and create mean itensity profile
Data=[];
mean_Data = [];


    for n = 1 : size(Output,2)
       Data(n,:) = Output{n}{2}(end,:);

    end

    mean_Data = mean(Data,1);

um = (1:1:length(mean_Data))*0.024;

%% Fit k_on rate from plus-end of intensity profile

for n = 3: length(mean_Data)
    [xData, yData] = prepareCurveData(um(1:n), mean_Data(1:n));

    ft = fittype( 'poly1' );

    [fitresult1{n-2}, gof1{n-2}] = fit( xData, yData, ft );

end

x = 3:1:length(mean_Data);
for n = 1 : length(gof1)
    y1(n) = gof1{n}.rsquare;
end


% 
% figure
% hold on
% plot(x,y);
% xlabel('fit length')
% ylabel('R-square')
% hold off


[~, optimum] = max(y1);
figure
hold on
scatter(um, mean_Data,'b.')
plot(fitresult1{optimum})
ylim([0 1])
hold off

%% Locate and plot edge between LD and HD and fit the profile

[~, optimum] = max(diff(mean_Data));

for n = 1: length(mean_Data)-optimum
    [xData, yData] = prepareCurveData(um(optimum-n:optimum+n), mean_Data(optimum-n:optimum+n));

    ft = fittype( 'poly1' );

    [fitresult2{n}, gof2{n}] = fit( xData, yData, ft );

end

for n = 1 : length(gof2)
    y2(n) = gof2{n}.rsquare;
end

[~, Opt] = max(y2);

figure
hold on
scatter(um, mean_Data,'b.')
plot(optimum*0.024, mean_Data(optimum), 'r*')
plot(fitresult2{Opt})
ylim([0 1])

xlabel('MT length (/mum)')
ylabel('Intensity (a.u.)');

hold off



%% Fit traffic jam slope

for n = 3: length(mean_Data)-1
    [xData, yData] = prepareCurveData(um(end-n:end), mean_Data(end-n:end));

    ft = fittype( 'poly1' );

    [fitresult3{n-2}, gof3{n-2}] = fit( xData, yData, ft );

end

x = 3:1:length(mean_Data);
for n = 1 : length(gof3)
    y3(n) = gof3{n}.rsquare;
end


% 
% figure
% hold on
% plot(x,y);
% xlabel('fit length')
% ylabel('R-square')
% hold off


[~, optimum] = max(y3);
figure
hold on
plot(fitresult3{optimum}, um, mean_Data)
ylim([0 1])
hold off



%% Fit equilibrium lattice state

steps = 1E3;
for n = 1: steps
    [xData, yData] = prepareCurveData(um, mean_Data);
    ft = fittype( 'poly1' );
    opts = fitoptions( 'Method', 'LinearLeastSquares');
    opts.Lower = [0 0];
    opts.Upper = [0 n/steps];
    

    [fitresult4{n}, gof4{n}] = fit( xData, yData, ft, opts );

end

x = 3:1:length(mean_Data)-1;
for n = 1 : length(gof4)
    y4(n) = gof4{n}.rsquare;
end

% 
figure
hold on
plot(x,y4);
xlabel('fit length')
ylabel('R-square')
hold off

[~, optimum] = max(y4);
figure
hold on
plot(fitresult4{optimum}, um, mean_Data)
ylim([0 1])
hold off

end
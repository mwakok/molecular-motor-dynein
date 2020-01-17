function fPlotProfiles(Results, Config, Save)

cutoff = Config.Stat_cutoff;
PixelSize = Config.PixelSize;
Slope = Results.Slope;
nProfiles = size(Results.Profiles,1);

minimum = nan(nProfiles,1);
maximum = nan(nProfiles,1);

% Subtract background to between [1 Inf]
for n = 1 : nProfiles
   minimum(n,1) = min(Results.Profiles{n,1}(:,4));  
   maximum(n,1) = max(Results.Profiles{n,1}(:,4));  
end
bkg = nanmean(minimum);

% Find valid profiles
for n = 1 : nProfiles
    N = Results.Profiles{n,1}(:,2);
    select(n) = max(N) > cutoff;    
end

ind = find(select == 1);

% Fit tip intensity with exponential 
[xData, yData] = prepareCurveData( cellfun(@(x) x, Results.Profiles(select,2)).*(PixelSize/1000),maximum(select)-bkg );
ft = fittype( 'a*(1-exp(-b*x))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0];
opts.Upper = [Inf Inf];
opts.StartPoint = [1 1];
fitresult = fit( xData, yData, ft, opts );

% norm  = fitresult.a;
norm  = 5.7724e+03;
%% Plot 1-D profiles sorted on MT length
subplot(2,3,[1,3]);

cmap = colormap(copper(length(ind)));
Figure_settings;
hold on
for n = 1 : length(ind)
        
    N = Results.Profiles{ind(n),1}(:,2);    
    % Plot only points with more datapoints than 75% of the cutoff
    i = find(N > 0.1 * cutoff);
    
    % Orient minus end on the right
%     xData = Results.Profiles{ind(n),1}(i,3)*(PixelSize/1000);
%     yData = Results.Profiles{ind(n),1}(i,4)-norm;
    
    % Orient minus end on the left
    xData = flip(Results.Profiles{ind(n),1}(i,3)*(PixelSize/1000)*-1);
    yData = flip(Results.Profiles{ind(n),1}(i,4)-bkg);
    
    % Plot profile
%     plot(xData, yData, 'Color', cmap(n,:), 'LineWidth', 1.5);
    plot(xData, yData./norm, 'Color', cmap(n,:), 'LineWidth', 1.5);

end
grid on
ylim([0 Inf]);
xlim([-2 10])
xticks([-2 0 2 4 6 8 10]);
title('Dynein profiles');
xlabel('Microtubule length (\mum)');
ylabel('Intensity (a.u.)');

hold off

% Plot the maximum intensity of the dynein signal 
subplot(2,3,4);
Figure_settings;
hold on 
xData = cellfun(@(x) x, Results.Profiles(select,2)).*(PixelSize/1000);
yData =  maximum(select)-bkg;
scatter(xData, yData, 32, 'k','filled');
% scatter(xData, yData./norm, 32, 'k','filled');
plot(xData, fitresult(xData),'--r','LineWidth',1.5);
% plot(xData, fitresult(xData)./norm,'--r','LineWidth',1.5);

ylim([0 1.1*max(yData)]);
% ylim([0 1.1*max(yData)]);
xlim([0 10]);
xticks([0 2 4 6 8 10]);
title('Intensity at the tip');
xlabel('Microtubule length (\mum)');
ylabel('Intensity (a.u.)');
hold off

% Plot the FWHM of the traffic jam
subplot(2,3,5);
Figure_settings;
hold on
xData = cellfun(@(x) x, Results.Profiles(select,2)).*(PixelSize/1000);
yData = cellfun(@(x) x, Results.Profiles(select,4)).*(PixelSize);
scatter(xData, yData, 32, 'k','filled');

ylim([0 1.1*max(yData)]);
xlim([0 10]);
xticks([0 2 4 6 8 10]);
title('FWHM of the traffic jam');
xlabel('Microtubule length (\mum)');
ylabel('FWHM [nm]');
hold off

% Plot the plus-end slope
subplot(2,3,6);
Figure_settings;
hold on
xData = cellfun(@(x) x, Results.Profiles(select,2)).*(PixelSize/1000);
% yData = cell2mat(Slope(:,4));
yData = cell2mat(Slope(:,4))./norm;
scatter(xData, yData, 32, 'k','filled');

ylim([0 1.1*max(yData)]);
xlim([0 10]);
xticks([0 2 4 6 8 10]);
title('Plus-end slope');
xlabel('Microtubule length (\mum)');
ylabel('Slope');
hold off

%% Save figure
if Save == 1 
    
    HomeFolder = Config.PathName;
    SaveFolder = strcat(HomeFolder, '\Analysis\');
    
    if ~exist(SaveFolder, 'dir')
       mkdir(SaveFolder) 
    end
    
    filename = strcat(SaveFolder, 'Figure_1');
    print(gcf, filename, '-dpng', '-r600');
    print(gcf, filename,'-depsc');
end

end
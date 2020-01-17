function fPlotHighDensity(Results, Config)

cutoff = Config.Stat_cutoff;
PixelSize = Config.PixelSize;
Profiles = Results.Profiles;
nDatasets = size(Profiles,1);

[rows, ~] = cellfun(@size, Profiles(:,2));
MT_length = nan(max(rows), nDatasets);
minimum = nan(max(rows), nDatasets);
maximum = nan(max(rows), nDatasets);

% Subtract background to between [1 Inf]
for n = 1 : nDatasets
   
    MT_length(1:rows(n),n) = cell2mat(Profiles{n,2}(:,2));
   
    for m = 1 : rows(n)
        minimum(m,n) = min(Profiles{n,2}{m,1}(:,4));  
        maximum(m,n) = max(Profiles{n,2}{m,1}(:,4));  
    end
   
end

% Calculate mean and std of microtuble length per bin
MT_length_mean = nanmean(MT_length,2);
MT_length_mean(:,2) = nanstd(MT_length,[],2);

norm = nanmean(minimum);

% Plot the results
% subplot(1,2,1);
% cmap = colormap(copper(nDatasets));
Figure_settings;

hold on 
for n = 1 : nDatasets
    xData = MT_length(:,n).*Config.PixelSize/1000;
    yData = maximum(:,n)-norm(n);
    Dmax_fit = fDyneinmax(xData, yData);
    ind = find(xData >1);
    scatter(xData(ind), yData(ind),'k', 'filled');  
%     plot(xData(ind), Dmax_fit(xData(ind)), '--r', 'LineWidth', 1.5);    
end

ylim([0 Inf]);
xlim([0 8]);
set(gca, '
xlabel('Microtubule length (\mum)');
ylabel('Intensity (a.u.)');
hold off

% subplot(1,2,2);
% Figure_settings;
% hold on 
% for n = 1 : max(rows)    
%     plot(Config.Concentrations, maximum(:,n)-norm,'Color',cmap(n,:),'LineWidth',1.5);    
% end
% ylim([0 Inf]);
% hold off

end
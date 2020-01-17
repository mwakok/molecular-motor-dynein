function fPlotLengths(Results, Config)

PixelSize = Config.PixelSize;
C = Config.Concentrations;
Profiles = Results.Profiles;
cutoff = Config.Stat_cutoff;
nDatasets = size(Profiles,1);

[rows, ~] = cellfun(@size, Profiles(:,2));
minimum = nan(max(rows), nDatasets);
maximum = nan(max(rows), nDatasets);

% Subtract background to between [1 Inf]
for n = 1 : nDatasets
    for m = 1 : rows(n)
        minimum(m,n) = min(Profiles{n,2}{m,1}(:,4));  
        maximum(m,n) = max(Profiles{n,2}{m,1}(:,4));  
    end   
end
%% Plot 1-D profiles of each microtubule length
[nLengths,~] = cellfun(@size, Profiles(:,2));
nLengths = min(nLengths);

for m = 1 : nLengths
%     nProfiles = size(Profiles{m,2},1);

    cmap = colormap(copper(length(C)));
%     select = [];
    subplot(ceil(nLengths/3),3,m);
    Figure_settings3;
    
    hold on     
    for n = 1 : length(C) 
            norm = nanmean(minimum(m,n));
            N = Profiles{n,2}{m,1}(:,2); 
           % Plot only points with more datapoints than 10% of the cutoff
            i = find(N > 0.75 * cutoff);
            plot(Profiles{n,2}{m,1}(i,3)*(PixelSize/1000), ...
                 Profiles{n,2}{m,1}(i,4)-norm, ...
                 'Color', cmap(n,:), 'LineWidth', 1.5);
    end
% %     grid on
    ylim([0 1.1*max(maximum(:))]);
    xlim([-10 2]);
% %     title('Dynein profiles');
    xlabel('Microtubule length (\mum)');
    ylabel('Intensity (a.u.)');
% 
    hold off
end
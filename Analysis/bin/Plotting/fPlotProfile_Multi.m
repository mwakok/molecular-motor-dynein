function fPlotProfile_Multi(Results, Config)

cutoff = Config.Stat_cutoff;
PixelSize = Config.PixelSize;
C = Config.Concentrations;
Profiles = Results.Profiles;
nDatasets = size(Profiles,1);

[rows, ~] = cellfun(@size, Profiles(:,2));
% MT_length = nan(max(rows), nDatasets);
minimum = nan(max(rows), nDatasets);
maximum = nan(max(rows), nDatasets);



%% Plot 1-D profiles of each dynein concentration
valid = cell(1,nDatasets);
for m = 1 : nDatasets
    select = [];    
    nProfiles = size(Profiles{m,2},1);
  
    for n = 1 : nProfiles
        N = Profiles{m,2}{n,1}(:,2);
        select(n) = max(N) > cutoff;
    end

    % Find valid profiles
    valid{m} = find(select == 1);

    % Calculate max and min intensity
    for k = 1 : length(valid{m})
        N = Profiles{m,2}{valid{m}(k),1}(:,2);
        i = find(N > 0.75 * cutoff);
        if ~isempty(i)
            minimum(k,m) = min(Profiles{m,2}{valid{m}(k),1}(i,4));  
            maximum(k,m) = max(Profiles{m,2}{valid{m}(k),1}(i,4));  
        else
            minimum(k,m) = NaN;  
            maximum(k,m) = NaN;
        end
    end   

    bkg(m) = nanmean(minimum(:,m));        
        
end
M = max(maximum(:));
%%    
for m = 1 : nDatasets
    cmap = colormap(copper(length(valid{m})));
    subplot(3,2,m);
    Figure_settings3;  
    hold on
    mm = 0;
    for n = 1 : length(valid{m})

        N = Profiles{m,2}{valid{m}(n),1}(:,2);

        % Plot only points with more datapoints than 10% of the cutoff
        i = find(N > 0.75 * cutoff);
        xData = flip(Results.Profiles{m,2}{valid{m}(n),1}(i,3)*(PixelSize/1000)*-1);
        yData = flip(Results.Profiles{m,2}{valid{m}(n),1}(i,4)-bkg(m));
        yData = yData ./ M;
        if max(yData) > mm
            mm = max(yData);
        end
        plot(xData, yData, 'Color', cmap(n,:), 'LineWidth', 1.5);             
    
    end
%     grid on
%     ylim([0 1.2*(max(maximum(:,m)))]);
    ylim([0 1.1*mm]);
    xlim([-2 10]);
    
%     title('Dynein profiles');
    xlabel('Microtubule length (\mum)');
    ylabel('Intensity (a.u.)');
   
    txt = strcat(num2str(C(m)), ' nM');      
    t =  text(7,mm, txt);
    
    t.Units = 'data';
    hold off
end

end
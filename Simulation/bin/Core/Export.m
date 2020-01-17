%% EXPORT.m
% Save the following files after running the simulation
% 1) All scripts required to rerun the simulation
% 2) Initialization parameters
% 3) Simulation results

%% Create Save Location
SaveFolder = strcat(pwd, '\', date);

if exist(SaveFolder) ~= 7
    SaveFolder = strcat(SaveFolder,'\1');
    mkdir(SaveFolder);
else
    SaveFolder = strcat(SaveFolder,'\',(num2str(size(dir(SaveFolder),1)-1)));
    mkdir(SaveFolder)    
end

%% Save scripts
% 1) SIM.m
% 2) fGillespie.m
% 3) fPropensity.m
% 4) fUpdate.m
% 5) Analyis.m

% files = {'SIM', 'fGillespie', 'fPropensity', 'fUpdate', 'Analysis'};
% 
% for n = 1 : length(files)
%     FileNameAndLocation = strcat(SaveFolder, '\Core\', files{n});
%     newbackup = sprintf('%s_backup%s.m',FileNameAndLocation);
%     currentfile = strcat(pwd, '\', files{n},'.m');
%     copyfile(currentfile,newbackup);
% end

%% Simulation results
% 1) Output.mat

filename = strcat(SaveFolder ,'\Results.mat');
save(filename, 'Results', 'simPa', '-v7.3');

g = groot;
if ~isempty(g.Children)
    filename = strcat(SaveFolder, '\Figure_1');
    print(gcf, filename, '-dpng', '-r600');
    print(gcf, filename,'-depsc');
end

clearvars filename SaveFolder g

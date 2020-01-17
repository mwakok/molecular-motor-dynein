%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulating dynein on a 1-D lattice
%
%
%
% Maurits Kok 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definition of model parameters
clear all
addpath(genpath('bin'))

% Load simulation parameters      
simPa = SIM_parameters;

% Preallocate output 
Results = cell(length(simPa.Var), simPa.MTs);

%% Simulate dynein motility

for i = 1 : length(simPa.Var)     
    % Run the simulation on parallel CPU cores
    parfor_progress(simPa.MTs);
    parfor n = 1 : simPa.MTs   
        
        % Execute the Gillespie algorithm
        Output = fGillespie(simPa, i);
        
        % Perform data sampling
        Sample = fSampling(Output, simPa.sampling);
        
        % Store result
        Results{i,n} = Sample;

        % Update progressbar
        parfor_progress;
    end    
    parfor_progress(0);
end
clearvars -EXCEPT Results simPa

%% Analyze simulated data

Analysis = fAnalyze_Sim(Results, simPa);

%% Plot the results

% fPlotProfiles_Sim_2(simPa, Results);

%% Save the output
% Export;
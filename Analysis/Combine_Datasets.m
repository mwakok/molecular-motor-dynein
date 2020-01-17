%%%------------------------------------------------------------------------
% Combine and analyse full dataset of multiple dynein concentrations
%
%
%
% Maurits Kok 2019
%
%%%------------------------------------------------------------------------
%% USER SETTINGSS
clear all
% Config.HomeFolder = 'C:\Users\mwako\Documents\Dynein'; % Default data folder 
Config.HomeFolder = 'K:\bn\mdo\Shared\Dynein_ToGo';
% Config.HomeFolder = 'D:\Dynein';

Config.Concentrations = [4 1.473 0.543 0.2 0.074 0.027]; % 2017/03/16 SPDynein
% Config.Concentrations = [10 2.5 0.625 0.156 0.039 0.0098]; % 2017/03/17 SPDynein
% Config.Concentrations = [8 2.67 0.89 0.3 0.1 0.03]; % 2017/03/20 WTynein
% Config.Concentrations = [4.62 1.54 0.51 0.17 0.06]; % 2017/03/21 WTDynein

Config.PixelSize = 160; % in nm
Config.Stat_cutoff = 200; % minimum number of MTs required to generate a mean profile

%% DATA IMPORT
addpath(genpath(pwd))
Config.PathName = uigetdir(Config.HomeFolder, 'Please select the TrafficJam Output folder');

% Import the analysed datasets
Results.Profiles = fImport_datasets(Config);

%% Plot collection results

fPlotHighDensity(Results, Config);
% fPlotFWHM(Results, Config);

% fPlotProfile_Multi(Results, Config);
% fPlotLengths(Results, Config);

% num = 3;
% fPlotProfile_Single(Results, Config, num);

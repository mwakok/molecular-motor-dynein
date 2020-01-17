%%%------------------------------------------------------------------------
% Analysis of dynein traffic jams
%
% ToDO
% - Fitting dynein profiles
% - Comparison to simulated dynein profiles
% - Ability to compare different dynein samples
% - Collect all waitbars
%
% Maurits Kok 2019
%
%%%------------------------------------------------------------------------
%% USER SETTINGS

% Config.HomeFolder = 'C:\Users\mwako\Documents\Dynein'; % Default data folder 
Config.HomeFolder = 'K:\bn\mdo\Shared\Dynein_ToGo';
% Config.HomeFolder = 'D:\Dynein';

Config.width = 3; % width of line to create mean profiles along microtubules
Config.gof_thresh = 0.9; % Threshold of goodness-of-fit (rsquare) for accepting a MT end fit

Config.bin_width = 1; % bin width in pixels for length distribution
Config.interp = 10; % Interpolation of the dynein profile (1 = no interpolation)

Config.PixelSize = 160; % Pixel size in nm
Config.Stat_cutoff = 200; % minimum number of MTs required to generate a mean profile

Config.Save = 0; % Save data (yes/no)

%% DATA IMPORT
addpath(genpath(pwd))
Config.PathName = uigetdir(Config.HomeFolder, 'Please select the Fiji Output folder');

% Import the images and coordinates
[Data, Results] = fImport(Config.PathName);

% Trim data to remove the (filler) pixels outside of the zoomed microtubule
Data = fTrim(Data);

% Determine if Multi CPU processing is possible.
Config.CPU = ParPool;

%% DATA TREATMENT

% Determine plus and minus end from the dynein intensity signal
[Data, Results.LocationJam] = fDyneinEnd(Data, Config);

% Determine position of the microtubule tips
[Results.MTend, Results.MTwidth] = fFitMT(Data, Config);

%% DATA SCREENING

% Remove microtubule bundles from analysis
Results.Bundles = fBundles(Data, Results, Config);

% Find poorly fitted and unidentified microtubule ends
Results.Ignore = fScreen(Data, Results, Config);

%% DATA ANALYSIS
% Sort profiles according to microtubule length
Results.Bin = fSortMT(Results, Config);

% Align microtubules and obtain mean intensity profiles
Results.Profiles = fAnalysis(Data, Results, Config);

% Calculate plus-end slope
Results.Slope = fSlope(Results, Config, 0);

%% Plot the profiles
fPlotProfiles(Results, Config, 0);

%% DEBUGGING
% Plot the data of a single microtubule trace

% Microtubule_Number = 1;
% fPlotSingle(Data, Results, Microtubule_Number);

%% SAVE RESULTS
fSave(Config, Data, Results);
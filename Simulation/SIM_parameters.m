function simPa = SIM_parameters

simPa = struct;

% Determine type of dynein
% 'WT' or 'SP'
simPa.DyneinType = 'SP';

% Basic lattice unit is size of dynein step, 1 unit = 24 nm
simPa.step = 24;    

simPa.L = 250;                      % Length lattice in hopping units                       
simPa.L_max = 300;                  % Max length lattice in hopping units
simPa.L_min = 30;                   % Min length lattice in hopping units

simPa.R_max = 50000;                % Maximum number of simulation steps                    
simPa.T_max = 500;                  % Add termination point after certain time (in seconds)
simPa.MTs = 1000;                    % Number of simulated microtubules per condition

simPa.Conv = 0;                     % Convolve the intensity profiles with a Gaussian PSF (true/false)

% Parameter scanning

% 0 = no scan ; 1 = MT length; 2 = [Dynein]; 3 = attachment rate; 
% 4 = detachment rate; bulk; 5 = detachment rate end; 6 = hopping rate
simPa.Scan = 0;                     % Select to vary a specific parameter
simPa.Scan_num = 10;                % Set number of different parameter values to scan

% Determine the sampling interval for saving the lattice configuration
% If sampling = 0, then only the last state will be saved. Otherwise, it
% determines the time interval (in seconds) at which to sample the output.
simPa.sampling = 0;                 % in seconds

% Concentration and rates

    % From Reck-Peterson et al. Cell 2006:
    %   Wild type yeast dynein:
    %       Runlength = 1.9 pm 0.2 um
    %       Velocity  = 85 pm 30 nm/sec
    %
    % From Cho et al. JCB 2008:
    %   Wild type yeast dynein:
    %       Runlength = 2.25 pm 0.14 um
    %       Velocity  = 73.9 pm 34.2 nm/sec   
    %   Super processive yeast dynein:
    %       Runlength = 4.39 pm 0.45 um
    %       Velocity  = 60.6 pm 18.9 nm/sec

% Wild-type dynein parameters
switch simPa.DyneinType
    case 'WT'
    simPa.Conc = 1.45;                          % Concentration in nM
    simPa.param(1) = 0.0025;                    % Attachment rate bulk [/nM /sec]
    simPa.param(2) = 73.9/2250;                 % Detachment rate bulk [/sec]
    simPa.param(3) = simPa.param(2);            % Detachment rate end lattice [/sec]
    simPa.param(4) = 73.9/simPa.step;           % Forward hopping rate [sitess/sec]
    simPa.param(5) = simPa.param(1);            % Attachment begin lattice
% Super processive dynein parameters    
    case 'SP'
    simPa.Conc = 2;                             % Concentration in nM
    simPa.param(1) = 0.0025;                    % Attachment rate bulk [/nM /sec]
    simPa.param(2) = 60.6/4390;                 % Detachment rate bulk [/sec]
    simPa.param(3) = simPa.param(2);            % Detachment rate end lattice [/sec]
    simPa.param(4) = 60.6/simPa.step;           % Forward hopping rate [sites/sec]
%     simPa.param(4) = 0; 
    simPa.param(5) = simPa.param(1);            % Attachment begin lattice
end

% Parameter scan options
switch simPa.Scan
    case 0 % No parameter scanning
        simPa.Var = 0;
    case 1 % Vary microtubule length
        simPa.Var = round(linspace(simPa.L_min, simPa.L_max, simPa.Scan_num));
    case 2 % Vary concentration between 0.01 and 10 nM
        simPa.Var = round(logspace(-2, 1, simPa.Scan_num),3);
    case 3 % Vary bulk attachment rate
        simPa.Var = round(linspace((1/2)*simPa.param(1), 1.5*simPa.param(1),simPa.Scan_num),4);
    case 4 % Vary bulk detachment rate
       simPa.Var = round(linspace((1/2)*simPa.param(2), 1.5*simPa.param(2),simPa.Scan_num),4);
    case 5 % Vary detachment rate minus end
        simPa.Var = round(linspace((1/5)*simPa.param(3), 5*simPa.param(3),simPa.Scan_num),4);
    case 6 % Vary hopping rate
         simPa.Var = round(linspace((1/2)*simPa.param(4), 1.5*simPa.param(4),simPa.Scan_num),1);
end
end
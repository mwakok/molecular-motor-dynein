function Output = fAnalyze_Sim(Results, simPa)

Output = struct;

nProfiles = size(Results,1);
extend = 80;

% Calculate mean profiles per microtuble length
Profiles = cell(1,nProfiles);
Profile_Dynein = cell(nProfiles,1);
Profile_MT = cell(nProfiles,1);

Param = simPa.Var;

switch simPa.Scan
    case 0 % No parameter scanning
        Str = [];
    case 1 % Vary microtubule length
        Str = 'Microtubule length (\mum)';
        Param = Param*(simPa.step/1000);
    case 2 % Vary concentration between 0.01 and 10 nM
        Str = 'Dynein [nM]';
    case 3 % Vary bulk attachment rate
        Str = 'Attachment bulk [/sec]'; 
    case 4 % Vary bulk detachment rate
        Str = 'Detachment bulk [/sec]';
    case 5 % Vary detachment rate minus end
        Str = 'Detachment end [/sec]';
    case 6 % Vary hopping rate
        Str = 'Hopping rate [nm/sec]';
        Param = Param*simPa.step;
end

for i = 1 : nProfiles  
    
    % Collect all profiles
    for n = 1 : size(Results,2)
       Profiles{i}(n,:) = Results{i,n}{2}(end,:);
    end
    
    % Calculate mean profiles
    Profile_Dynein{i,1} = flip(mean(Profiles{i},1));
    
    % Interpolate profiles
    L = length(Profile_Dynein{i,1});
    Position{i,1} = (1-extend:1:L+extend);

    % Align on microtubule end
%     Position{i,1} = Position{i,1};
  
    % Extend profiles
    Profile_Dynein{i,1} = [zeros(1,extend) Profile_Dynein{i,1} zeros(1,extend)];
    Profile_MT{i,1} = [zeros(1,extend) ones(1,L) zeros(1,extend)];
    
end

% Convolve the mean profiles with a Gaussian
FWHM = 700; % width of experimental PSF (in nm)
sigma = FWHM/2.335; 
sigma = sigma / simPa.step; % account for hopping step size

% Construct Gaussian filter
sz = 100;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

% Filter dynein profiles
for n = 1 : nProfiles
%     Profiles_Gauss{n,1} = filter(gaussFilter,1, Profile{n,1});
    Dynein_Gauss{n,1} = conv(Profile_Dynein{n,1}, gaussFilter, 'same');
    MT_Gauss{n,1} = conv(Profile_MT{n,1}, gaussFilter, 'same');
end

% Calculate maximum of each profile
for n = 1 : nProfiles
    maximum_D(n) = max(Dynein_Gauss{n,1});
    maximum_MT(n) = max(MT_Gauss{n,1});
end

% Fit maximum dynein intensity to 
% Dmax_fit = fDyneinmax(Param, maximum_D);

% Calculate FWHM of the dynein profile
I_half = maximum_D/2;
for n = 1 : nProfiles
    x_line = [min(Position{n,1}) max(Position{n,1})];
    y_line = [1 1]*I_half(n);
    xData = Position{n,1};
    yData = Dynein_Gauss{n,1};

%     hold on
%     plot(xData, yData);
%     plot(x_line, y_line);
%     hold off
    
    [xi, ~] = polyxpoly(xData, yData, x_line, y_line);   
    if length(xi) == 2
        FWHM(n) = abs(diff(xi));
    else
        FWHM(n) = NaN;
    end
end

% Calculate plus-end slope of the intensity profile
% Slope = fSlope_Sim(Dynein_Gauss, simPa, extend);
Slope = fSlope_Sim(Profile_Dynein, simPa, extend);

% Collect data for output
Output.Position = Position;
Output.Dynein = Profile_Dynein;
Output.MT = Profile_MT;
Output.Dynein_Gauss = Dynein_Gauss;
Output.MT_Gauss = MT_Gauss;
Output.Slope = Slope;
Output.FWHM = FWHM;
Output.Tip_accumulation = maximum_D;


end
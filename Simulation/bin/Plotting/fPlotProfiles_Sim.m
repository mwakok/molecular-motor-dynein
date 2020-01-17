function fPlotProfiles_Sim(simPa, Results)

nProfiles = size(Results,1);

% Position = Analysis.Position;
% Profile_Dynein = Analysis.Profile_Dynein;
% Profile_MT = Analysis.Profile_MT;
% Dynein = Analysis.Dynein;
% MT = Analysis.MT;
% Dynein_Gauss = Analysis.Dynein_Gauss;
% FWHM = Analysis.FWHM;
% Slope = Analysis.Slope;

extend = 80;

% Calculate mean profiles per microtuble length
Profiles = cell(1,nProfiles);
Profile_Dynein = cell(nProfiles,1);
Profile_MT = cell(nProfiles,1);

Var = simPa.Var;

switch simPa.Scan
    case 0 % No parameter scanning
        Str = [];
    case 1 % Vary microtubule length
        Str = 'Microtubule length (\mum)';
        Var = Var*(simPa.step/1000);
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
        Var = Var*simPa.step;
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
Dmax_fit = fDyneinmax(Var, maximum_D);

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
Slope = fSlope_Sim(Dynein_Gauss, simPa, extend);

% Calculate theoretical tip intensity 
% switch simPa.Scan
%     case 1
%         tip = (simPa.param(4)*simPa.param(1)*simPa.Conc*Var)/simPa.param(3);
%         tip = tip *simPa.step/1000;
%     case 2
%         
% end

% Normalize complete dataset to [0 1]
norm = 0.8;
%% Plot the profiles
subplot(2,3,[1,3]);
cmap = colormap(copper(nProfiles));
Figure_settings;
hold on
for n = 1 : nProfiles   
    xData = Position{n,1}*(simPa.step/1000);
%     yData = Profile_Dynein{n,1};
%     yData = Dynein_Gauss{n,1};   
    yData = Dynein_Gauss{n,1}./norm;   
    plot(xData, yData, 'Color', cmap(n,:), 'LineWidth', 1.5);
end

grid on
ylim([0 (max(maximum_D)./norm)*1.1]);
xlim([-2 10]);

switch simPa.DyneinType
    case 'WT'
        title('Simulated WT dynein profiles');
    case 'SP'
        title('Simulated SP dynein profiles');
end

xlabel('Length (\mum)');
ylabel('Intensity (a.u.)');

hold off

% Plot the maximum intensity of the dynein signal 
subplot(2,3,4);
Figure_settings;
hold on 
xData = Var;
yData =  maximum_D./norm;
scatter( xData, yData, 32, 'k','filled');
% plot(xData, Dmax_fit(xData)./norm, '--r', 'LineWidth', 1.5);
% plot(xData, tip, '--r', 'LineWidth', 1.5);
% ylim([0 1.1*(max(yData)./norm)]);
ylim([0 Inf]);

if simPa.Scan == 1
    xlim([0 10]);
elseif simPa.Scan == 2
    set(gca, 'XScale','log');
end

title('Intensity at the tip');
xlabel(Str);
ylabel('Intensity (a.u.)');
hold off

% Plot the FWHM of the traffic jam
subplot(2,3,5);
Figure_settings;
hold on
xData = Var;
yData = FWHM*simPa.step;
scatter(xData, yData, 32, 'k','filled');

ylim([0 1.1*max(yData)]);

if simPa.Scan == 1
    xlim([0 10]);
elseif simPa.Scan == 2
    set(gca, 'XScale','log');
end

title('FWHM of the traffic jam');
xlabel(Str);
ylabel('FWHM [nm]');
hold off

% Plot the plus-end slope
subplot(2,3,6);
Figure_settings;
hold on
xData = Var;
yData = cell2mat(Slope(:,4))./norm;
scatter(xData, yData, 32, 'k','filled');
yData = cell2mat(Slope(:,5));
scatter(xData, yData, 32, 'r');
ylim([0 1.2*max(yData)]);

if simPa.Scan == 1
    xlim([0 10]);
elseif simPa.Scan == 2
    set(gca, 'XScale','log');
end

legend('Simulation','Theory','Location','southeast');

title('Plus-end slope');
xlabel(Str);
ylabel('Slope');
hold off

end
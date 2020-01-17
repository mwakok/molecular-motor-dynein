function fPlotSingle(Data, Results, N )

% Create figure with two subplots
%   1) The image of the dynein jam
%   2) The mean intensity profile
%      Add the fitted 'poly1'

width = 5;

figure;
subplot(3,1,1);
colormap gray
imagesc(Data{N,3});

subplot(3,1,2);
colormap gray
imagesc(Data{N,4});

subplot(3,1,3);
hold on

I_seed = Data{N,3};
I_dynein = Data{N,4};

[row,~] = size(I_seed);
c = ceil(row/2);
I_seed_mean = mean(I_seed(c-width:c+width,:));
I_seed_mean = I_seed_mean - min(I_seed_mean);
I_seed_mean = I_seed_mean ./ max(I_seed_mean);

I_dynein_mean = mean(I_dynein(c-width:c+width,:));
I_dynein_mean = I_dynein_mean - min(I_dynein_mean);
I_dynein_mean = I_dynein_mean ./ max(I_dynein_mean);

plot(I_seed_mean, 'r', 'LineWidth', 2);

plot(I_dynein_mean, 'g', 'LineWidth', 2);

% Add the fitted microtubule ends
if isfield(Results, 'MTend')
    Pos1 = Results.MTend(N,1);
    Pos2 = Results.MTend(N,2);
%     Pos = Results.MTend{N,1};
    plot([Pos1 Pos1], [0, 1], '--k');
    plot([Pos2 Pos2], [0, 1], '--k');
end

xlim([1 size(I_seed_mean,2)]);

% Add text to assign plus and minus end
if isfield(Results, 'LocationJam')
    sign = Results.LocationJam(N,3);
    x = [2 size(I_seed_mean,2)-2];
    y = [0.9 0.9];
    if sign == -1 || sign == 1
        text(x(1), y(1), '+', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
        text(x(2), y(2), '-', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    elseif sign == 0
        text(x(1), y(1), '?', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
        text(x(2), y(2), '?', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    end
    
end

ylabel('Norm. Intensity (a.u.)');
xlabel('Pixels');
hold off
end
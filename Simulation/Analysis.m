%%%%%%%% Analysis and plotting
%
%
%
%

%% Display lattice density over time
figure
hold on
for n = 1 : length(Results)

   Data = sum(Results{n}{1,2},2);
   Time = Results{n}{1,1};
   Time = Time';
   
   plot(Time,Data);
   xlabel('Time(sec)')
   ylabel('Occupancy lattice')
    
end
hold off

%% Plot average density per position on the lattice
Data= zeros(length(Results), simPa.L);
for n = 1 : length(Results)
   Data(n,:) = Results{1,n}{2}(end,:);
end

mean_Data = mean(Data,1);

ind = find(mean_Data < 0);
mean_Data(ind) = NaN;
um = (1:1:length(mean_Data))*0.024; 

figure
plot(um, mean_Data)
xlabel('Microtubule length (um)')
ylabel('Occupancy lattice')
%% Plot average density per position on the lattice for different MT lengths
Data=[];
mean_Data = [];

for i = 1 : size(Results,1)    
    for n = 1 : size(Results,2)
       Data{i}(n,:) = Results{i,n}{2}(end,:);

    end

    mean_Data{i} = mean(Data{i},1);
end

figure
hold on
for n = 1 : size(Results,1)
    um = (1:1:length(mean_Data{n}))*0.024; 
    plot(um, mean_Data{n})
end
hold off

% Align profiles at minus end
max_L = size(mean_Data{end},2);
for k = 1 : length(mean_Data)
    
    temp_Data{k} = fliplr(mean_Data{k});
%     temp_Data{k} = mean_Data{k};
    temp_Data{k}(end+1:max_L) = 0;
    align_Data(k,:) = temp_Data{k};
end

um = (1:1:max_L)*0.024; 
figure
hold on
for n = 1 : size(align_Data,1)
    plot(um, align_Data(n,:))
end
% axis([0 5 0 1]);
hold off

% Surface plot 
% [X,Y] = meshgrid(um, linspace(42,202,6)./42);
% surf(X,Y,align_Data);


%% Plot average density per lattice site for different times
Data = [];
Select = 1;
A = [];
for n = 1 : size(Results,2)
A(n) = size(Results{Select,n}{2},1);
end

for k = 1 : min(A)
    for n = 1 : length(Results)
       Data{k,1}(n,:) = Results{Select,n}{1,2}(k,:);
    end
    Data{k,1} = mean(Data{k,1},1);
end


um = (1:1:length(Data{1}))*0.024; 
figure
hold on
for i = 1 : length(Data)
    plot(um, Data{i})
end
hold off


%% Plot kymo of tip density
Select = 1;
A = [];
for n = 1 : size(Results,2)
A(n) = size(Results{Select,n}{2},1);
end

Data = cell(min(A),1);
for k = 1 : min(A)
    for n = 1 : length(Results)
       Data{k,1}(n,:) = Results{Select,n}{1,2}(k,:);
    end
    Data{k,1} = mean(Data{k,1},1);
end

um = (1:1:length(Data{1}))*0.024; 
[X,Y] = meshgrid(um, (1:1:min(A)));
for n = 1 : min(A)
   Z(n,:) = Data{n}; 
end

figure
surf(X,Y,Z);
set(gca, 'YDir', 'reverse');
view(0, 90);
xlabel('MT length (\mum)')
ylabel('Time (min)')

%% Display and fit runlength distribution

% bins = histx(cellfun(@(x) x(end,1),Output),'fd');
% [H,N] = hist(cellfun(@(x) x(end,1),Output),length(bins));
% 
% % Fit dwell times
% [xData, yData] = prepareCurveData( N, H );
% ft = fittype( 'exp1' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% 
% % Fit model to data.
% [fitresult, gof] = fit(xData, yData, ft, opts );
% 
% % Plot fit with data.
% figure
% h = plot( fitresult, xData, yData );
% legend( h, 'Dwelltimes', 'Exponential fit', 'Location', 'NorthEast' );
% % Label axes
% xlabel('Dwell time')
% ylabel Frequency
% grid on
% 
% display(strcat('Decay rate = ', {' '}, num2str(fitresult.b)));


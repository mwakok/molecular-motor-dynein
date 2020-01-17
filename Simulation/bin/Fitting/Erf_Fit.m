ft = fittype( 'b*erf((x-x0)/a)+C', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0 0];


%% Channel 1
Num = 1;

for n = 1 : size(Stack{Num},1)
       
    YData = double(Stack{Num}(n,:))';
    XData = (1:1:length(YData))';
    opts.StartPoint = [mean(YData) 1 mean(YData) 1];
    
    fitresult1{n} = fit( XData, YData, ft, opts );
    
end

for n = 1 : size(Stack{Num},1)
    
    Output{Num}(n) = fitresult1{n}.x0;
        
end

%% Channel 2
Num = 2;
for n = 1 : size(Stack{Num},1)
    
    
    YData = double(Stack{Num}(n,:))';
    YData = YData(1:floor(Output{1}(n)));
    XData = (1:1:length(YData))';
    opts.StartPoint = [mean(YData) 1 mean(YData) 1];
    
    fitresult2{n} = fit( XData, YData, ft, opts );
    
end


for n = 1 : size(Stack{Num},1)
    
    Output{Num}(n) = fitresult2{n}.x0;
        
end

%% Plot Fits and compare to data



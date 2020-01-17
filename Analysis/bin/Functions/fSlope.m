function Slope = fSlope(Results, Config, Debug)

nProfiles = size(Results.Profiles,1);
PixelSize = Config.PixelSize;
cutoff = Config.Stat_cutoff;

Slope = cell(nProfiles,4);

% Find valid profiles
for n = 1 : nProfiles
    N = Results.Profiles{n,1}(:,2);
    select(n) = max(N) > cutoff;    
end

index = find(select == 1);
h = waitbar(0,'Fitting plus-end slope...');

for n = 1 : length(index)
    
    N = Results.Profiles{index(n),1}(:,2);   
    i = find(N > 0.5 * cutoff);
    
    Slope{n,1} = Results.Profiles{index(n),1}(i,3);
    Slope{n,2} = Results.Profiles{index(n),1}(i,4);
    
    for m = 1 : length(Slope{n})-2
       ft = fittype('poly1');
       y = Slope{n,2}(1:m+2)';
       x = (0:1:length(y)-1)*PixelSize*mean(diff(Slope{n,1})); % in nm
       [xData, yData] = prepareCurveData( x , y );
       [fitresult, gof] = fit( xData, yData, ft );
       
       Slope{n,3}(end+1,:) = [fitresult.p1 gof.rsquare];
        
    end
    
    ind = find(Slope{n,3}(:,2) > 0.97);
    if ~isempty(ind)    
        Slope{n,4} = mean(Slope{n,3}(ind));
    else
        Slope{n,4} = NaN;
    end
    
    waitbar(n/length(index));
    
end

close(h);

if Debug == 1
   % Plot mean linear fit
    
    
    
end

end
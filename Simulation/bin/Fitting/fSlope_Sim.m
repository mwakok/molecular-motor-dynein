function Slope = fSlope_Sim(Intensity_Profiles, simPa, extend)
% Calculate plus-end slope of the intensity profile

nProfiles = length(Intensity_Profiles);
Slope = cell(nProfiles,4);
for n = 1 : nProfiles 

    Slope{n,2} = flip(Intensity_Profiles{n,1}(extend+1:end-extend-1));
%     Slope{n,2} = flip(Intensity_Profiles{n,1}(extend+1:end-extend-1));
    Slope{n,1} = (0:1:length(Slope{n,2})-1)*(simPa.step/1000); % 
    
    for m = 1 : length(Slope{n})-2
       ft = fittype('poly1');
       x = Slope{n,1}(1:m+2);
       y = Slope{n,2}(1:m+2);
%        x = (0:1:length(y)-1)*simPa.step; % in nm

       [xData, yData] = prepareCurveData( x , y );
       [fitresult, gof] = fit( xData, yData, ft );
       
       Slope{n,3}(end+1,:) = [fitresult.p1 gof.rsquare];
        
    end
    
    
    % Find optimal slope parameters by looking at the evolution of the
    % rsquare value
    
    rS = abs(diff(Slope{n,3}(:,2)));
    ind = find(rS < 5E-3, 1, 'first');
    
%     ind = find(Slope{n,3}(:,2) > 0.995,1,'last');
%     ind = find(Slope{n,3}(:,2) > 0.96);
%     [~,ind] = max(Slope{n,3}(:,2));
    if ~isempty(ind)    
        Slope{n,4} = mean(Slope{n,3}(ind,1));
    else
        Slope{n,4} = NaN;
    end
    
    
    
%     Adjust units of plus-end slope to /nM
    if simPa.Scan == 2
%         Slope{n,4} = Slope{n,4} / simPa.Var(n);
        % Theoretical slope
        if simPa.Scan == 3
            Slope{n,5} = simPa.Var(n)/simPa.param(4)/simPa.step;
        elseif simPa.Scan == 6
            Slope{n,5} = simPa.param(1)/simPa.Var(n)/simPa.step;
        else
            Slope{n,5} = simPa.param(1)/simPa.param(4)/simPa.step;

        end
    else
%         Slope{n,4} = Slope{n,4} / simPa.Conc;
        % Theoretical slope
       if simPa.Scan == 3
            Slope{n,5} = simPa.Var(n)/simPa.param(4)/simPa.step;
        elseif simPa.Scan == 6
            Slope{n,5} = simPa.param(1)/simPa.Var(n)/simPa.step;
        else
            Slope{n,5} = (simPa.Conc*simPa.param(1))/(simPa.param(4)*(simPa.step/1000));

        end
    end

    
end

end
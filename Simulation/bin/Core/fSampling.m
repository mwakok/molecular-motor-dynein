function Output = fSampling(Input, sampling) 

    if sampling == 0       
                Input{1,1}(:,1:end-1) = []; %Just save final state
                Input{1,2}(1:end-1,:) = []; %Just save final state
                Output = Input;
    else
        tempOutput = cell(1,2);
        for k = 1 : floor(Input{1}(end) / sampling)
            ind = find(Input{1} > k*sampling,1);
            tempOutput{1,1}(k,:) = Input{1,1}(1,ind); 
            tempOutput{1,2}(k,:) = Input{1,2}(ind,:);
        end
        
        Output = tempOutput;

    end

end
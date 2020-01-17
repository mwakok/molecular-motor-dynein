function Output = fTrim(Data)

Output = Data;

h = waitbar(0, 'Trimming dataset...');

for n = 1 : size(Data,1)
    inds = [];
    for m = 1 : size(Data{n,3},2)    
         if length(unique(Data{n,3}(:,m))) == 1
            inds = [inds m];
         end
    end
    Output{n,3}(:,inds) = [];
    Output{n,4}(:,inds) = [];
    waitbar(n/size(Data,1), h); 
end

close(h);
end
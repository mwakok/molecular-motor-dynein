function Output = fSortMT(Results, Config)
% Sort the microtubules based on length

% Check inputs of use default values
if nargin < 2
    bin_width = 5;
else 
    bin_width = Config.bin_width;
end

% Initialize output vector
MT_length = nan(size(Results.MTend,1),1);

h = waitbar(0,'Sorting microtubules...');

% Calculate the length of each microtubule
for n = 1 : size(Results.MTend,1)
    
    % Check if data is OK
    if Results.Ignore(n,1) == 0   
         MT_length(n,1) = Results.MTend(n,2) - Results.MTend(n,1);
         if MT_length(n,1) < 0
             MT_length(n,1) = NaN;
         end
    else
        MT_length(n,1) = NaN;
    end
    waitbar(n/size(Results.MTend,1),h);
end

close(h);

% Sort the MT lengths into bins
edges = 0:bin_width:ceil(max(MT_length)/bin_width);
[~, ~, bin] = histcounts(MT_length, edges);

Output(:,1) = bin;
Output(:,2) = MT_length;
end
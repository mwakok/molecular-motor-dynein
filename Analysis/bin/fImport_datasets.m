function Output = fImport_datasets(Config)

if Config.PathName == 0
    Output = [];
    Results = struct;
    return
else 
    PathName = Config.PathName;
end

% List of all datasets 
list = dir(PathName);
list(1:2,:) = [];

% Initialize output vector
Output = cell(length(list),2);

for n = 1: length(list)
   
   Output{n,1} = list(n).name;
   
   if contains(list(n).name, '.mat')
       source = strcat(PathName, '\', list(n).name);
       newData = load('-mat', source);          
       Output{n,2} = newData.Results.Profiles; 
   end
end


end

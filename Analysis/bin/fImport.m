function [Output, Results] = fImport(PathName)

if PathName == 0
    Output = [];
    Results = struct;
    return
end

PathName_MT = strcat(PathName, '\Microtubules');

% Import the stacks
source = strcat(PathName_MT, '\Microtubules.tif');
Stack_MT = tiffread2(source);
source = strcat(PathName_MT, '\Dynein.tif');
Stack_Dynein = tiffread2(source);

% Initialize output
Output = cell(1,1);

% Import text file
opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [1, Inf];
opts.Delimiter = "_";
opts.VariableTypes = ["double", "double"];
opts = setvaropts(opts, [1, 2], "TrimNonNumeric", true);
opts = setvaropts(opts, [1, 2], "ThousandsSeparator", ",");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
Microtubules = readtable(strcat(PathName, '\Microtubules.txt'), opts);
Microtubules = table2array(Microtubules);

% Extract framenumber and seed name
frame = Microtubules(:,1);
seed = Microtubules(:,2);

% Store data
for n = 1 : length(frame)
    Output{n,1} = frame(n);
    Output{n,2} = strcat('C',num2str(seed(n)));
    Output{n,3} = double(Stack_MT(n).data);        
    Output{n,4} = double(Stack_Dynein(n).data);
end

Results = struct;

end

function Output = fScreen(Data, Results, Config)

% Intialize output vector
Output = zeros(size(Data, 1), 1);

% Maximum offset between maximum dynein and microtubule tip
offset = 10;

for n = 1 : size(Data, 1)

    % Check whether the microtubule is a bundle
    if Results.Bundles(n,1) == 1
        Output(n,1) = 1;
    end
    
    % Check whether the plus and minus end are identified
    if Results.LocationJam(n,3) == 0
        Output(n,1) = 1;
    end
    
    % Check whether the microtubule ends were properly fitted based on the
    % goodness-of-fit
    if Results.MTend(n,5) < Config.gof_thresh || Results.MTend(n,6) < Config.gof_thresh
        Output(n,1) = 1;
    end
    
    % Check whether the dynein profile has a maximum near the minus end
    [~, Pos_dynein] = max(mean(Data{n,4}));
    if Results.LocationJam(n,3) == 1 && abs(Pos_dynein - Results.MTend(n,2)) > offset
         Output(n,1) = 1;
    end
    
end

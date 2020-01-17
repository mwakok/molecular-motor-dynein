function Output = fRegistration(Data, Results)


nSeeds = size(Data,1);
Data_reg = cell(nSeeds,1);

% Transform the data so that the dynein jam is on the left hand side
for n = 1 : nSeeds
    
   if Results.LocationJam(n,3) == 1
      Data_reg{n,1}(:,:,1) = fliplr(Data{n,3}(:,:,1));
      Data_reg{n,1}(:,:,2) = fliplr(Data{n,3}(:,:,2));
   elseif Results.LocationJam(n,3) ==  -1
        Data_reg{n,1} = Data{n,3};
   else
        Data_reg{n,1} = [];
   end
        
end

% OPTIONAL debugging: plot profiles before registration
fPlotProfiles(Data, 3);

% Calculate the (linear) subpixel registration shift

% Use theoretical template? 
% Based on mean fitted sigma?
f = @(x) (1/2)*erfc((x)/(sqrt(2)*-2)); 


% OPTIONAL debugging: plot profiles after registration
% fPlotProfiles(Data, 3);

end
%%%%%%%%%%%%%
% fGillespie
% 
% Using the Gillespie algorithm to simulate dynein movement

function Output =  fGillespie(simPa, index)

%%% Extract simulation parameters
param = simPa.param;
Conc = simPa.Conc;
lattice = simPa.L;
switch simPa.Scan           
    case 1
        lattice = simPa.Var(index);
    case 2
        Conc = simPa.Var(index);
    case 3
        param(1) = simPa.Var(index);
    case 4
        param(2) = simPa.Var(index);
    case 5
        param(3) = simPa.Var(index);
    case 6
        param(4) = simPa.Var(index);
end

param(1) = Conc*param(1);
param(5) = Conc*param(5);

R_max = simPa.R_max;
T_max = simPa.T_max;

%%% Pre-drawing of random numbers for simulation
rand_nums = rand(2,R_max);

%%% Preallocation of containers for the simulation time course
lattice_cont = zeros(R_max + 1, lattice); % Container for nn time course
tt_cont = zeros(1,R_max+1); % Container for time points of reactions

%%% Initialize simulation
R_counter = 0;
tt = 0;

%%% Actual simulation
while R_max > R_counter && T_max+1 > tt
     
    R_counter = R_counter + 1;
    
    % Calculate the propensities for all events
    [aa, Idx] = fPropensity(param, lattice_cont(R_counter,:)); 
    
    % Draw waiting time
    delta_t = -log(rand_nums(1,R_counter)) ./ sum(aa);
    
    valid_inds = aa > 0; % Find the indices that refer to valid events
    valid_aa = aa(valid_inds); % Use only valid events
    valid_changes = find(valid_inds); % Use only valid events
    
    if isempty(valid_changes)
        break
    end

    % Construct intervals
    selection_intvl = cumsum(valid_aa); % Cumulative sum
    selection_intvl = selection_intvl./selection_intvl(end); % Normalize to [0,1]
    
    % Pick segment
    selected_ind = find(selection_intvl > rand_nums(2,R_counter),1,'first');  
    update_ind = Idx{valid_changes(selected_ind)};
    
    % Update the lattice configuration
    lattice_cont(R_counter+1,:) = fUpdate(valid_changes(selected_ind),...
                                                  update_ind,...
                                                  lattice_cont(R_counter,:));
    
    % Update time
    tt = tt + delta_t;
    tt_cont(R_counter+1) = tt;
    
end

Output{1} = tt_cont(1:R_counter); 
Output{2} = lattice_cont(1:R_counter,:);
end

%%%%%%%%%%%% 
% fEvents
% 
% Event types
% 1) Attachment
% 2) Detachment
% 3) Forward hopping
% 4) Backward hopping

function Result = fUpdate_lattice(event, selection, lattice)

%%%% Attachment event
if event == 1 

    idx = randi([1 length(selection)]); % Random selection of lattice site
    
    lattice(1, selection(idx)) = lattice(1, selection(idx)) + 1;
    Result = lattice;

%%%% Detachment event
elseif event == 2
    
    idx = randi([1 length(selection)]); % Random selection of lattice site
    
    lattice(1, selection(idx)) = lattice(1, selection(idx)) - 1;
    Result = lattice;

%%%% Detachment event at end 
elseif event == 3
    
    lattice(1,end) = lattice(1,end) - 1;
    Result = lattice;
    
%%%% Forward hopping event
elseif event == 4
    
    idx = randi([1 length(selection)]); % Random selection of lattice site
    
    lattice(1, selection(idx)) = lattice(1, selection(idx)) - 1;
    lattice(1, selection(idx) +1) = lattice(1, selection(idx) +1) + 1;
    
    Result = lattice;
    
end

end

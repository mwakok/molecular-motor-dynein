%%%%%%%%%%%%%%%
% fUpdate 
%
% Update list of possible events
%
%

function [aa, Idx] = fPropensity_lattice(rates, state)

% The state is the current particle distribution on the 1-D lattice
% Count the number of each possible event
%
% Event 1) Attachment of a particle to an empty spot
% Event 2) Detachment fo a particle from an occupied spot
% Event 3) Forward hopping
% Event 4) Backward hopping
% 

%% Number of empty spots
Idx{1} = find(state == 0);

%% Number of occupied spots on the lattice
Idx{2} = find(state(1:end-1) == 1); % Excluding final site

%% Occupied lattice site at the end
Idx{3} = find(state(end) == 1);

%% Number of possible forward hopping events
% 1) Forward hopping is only allowed on the 1-D lattice, i.e. max hopping events is
%    Lattice-1
% 2) Forward hopping is only allowed onto an empty spot

D = diff(state);
ind1 = find(state(1:end-1) == 1);
ind2 = find(D ~= 0 & D ~=-2);

comp = ismember(ind1, ind2);
if sum(comp) ~= 0
    Idx{4} = ind1(comp);
else 
    Idx{4} = [];
end


%% Correct event propensity

aa(1) = length(Idx{1}) * rates(1);
aa(2) = length(Idx{2}) * rates(2);
aa(3) = length(Idx{3}) * rates(3);
aa(4) = length(Idx{4}) * rates(4);

end


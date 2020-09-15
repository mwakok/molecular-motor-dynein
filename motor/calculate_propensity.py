import numpy as np


def propensity(rates, lattice):
    num_event_1 = np.count_nonzero(lattice == 0)  # Empty sites
    num_event_2 = np.count_nonzero(lattice[:-1] == 1)  # Occupied sites
    num_event_3 = lattice[-1]  # Lattice end
    num_event_4 = np.count_nonzero(
        (lattice[1:] - lattice[:-1]) == -1)  # Foward hopping
    pp = np.multiply(
        rates, [num_event_1, num_event_2, num_event_3, num_event_4])

    return pp


def update_state(event, state):
    if event == 0:  # Attachment event
        pos = np.nonzero(state == 0)[0]
        index = np.random.choice(pos)
        state[index] += 1
    elif event == 1:  # Detachment event lattice
        pos = np.nonzero(state[:-1] == 1)[0]
        index = np.random.choice(pos)
        state[index] -= 1
    elif event == 2:  # Detachment event lattice end
        state[-1] -= 1
    elif event == 3:  # Forward hopping event
        pos = np.nonzero((state[1:] - state[:-1]) == -1)[0]
        index = np.random.choice(pos)
        state[index] -= 1
        state[index + 1] += 1

    return state

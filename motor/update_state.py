import numpy as np


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

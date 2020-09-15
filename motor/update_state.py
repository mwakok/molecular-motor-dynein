import numpy


def update_state(event, state):
    """ Update the state of the lattice

    Parameters
    ----------
    event : int
        type of event that occurs
    state : numpy.ndarray
        current lattice state

    Returns
    -------
    state : numpy.ndarray
        array that contains the updated lattice state

    """

    if event == 0:  # Attachment event
        pos = numpy.nonzero(state == 0)[0]
        index = numpy.random.choice(pos)
        state[index] += 1
    elif event == 1:  # Detachment event lattice
        pos = numpy.nonzero(state[:-1] == 1)[0]
        index = numpy.random.choice(pos)
        state[index] -= 1
    elif event == 2:  # Detachment event lattice end
        state[-1] -= 1
    elif event == 3:  # Forward hopping event
        pos = numpy.nonzero((state[1:] - state[:-1]) == -1)[0]
        index = numpy.random.choice(pos)
        state[index] -= 1
        state[index + 1] += 1

    return state

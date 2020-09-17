import numpy


def update_state(seleted_event, lattice_state):
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

    if seleted_event == 0:  # Attachment event
        pos = numpy.nonzero(lattice_state == 0)[0]
        index = numpy.random.choice(pos)
        lattice_state[index] += 1

    elif seleted_event == 1:  # Detachment event lattice
        pos = numpy.nonzero(lattice_state[:-1] == 1)[0]
        index = numpy.random.choice(pos)
        lattice_state[index] -= 1

    elif seleted_event == 2:  # Detachment event lattice end
        lattice_state[-1] -= 1

    elif seleted_event == 3:  # Forward hopping event
        pos = numpy.nonzero((lattice_state[1:] - lattice_state[:-1]) == -1)[0]
        index = numpy.random.choice(pos)
        lattice_state[index] -= 1
        lattice_state[index + 1] += 1

    return lattice_state

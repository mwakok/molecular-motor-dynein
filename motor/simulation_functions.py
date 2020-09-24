import numpy as np


def event_type(selection):
    """
    Define the different event types for string comparison

    Parameters
    ----------
    selection : int
        Selected event type

    Returns
    -------
    event_string : string
        String of the selected event type
    """

    events = {0: "attach", 1: "detach", 2: "detach_end", 3: "forward_hop"}
    event_string = events[selection]

    return event_string


def calculate_propensity(kinetic_rates, lattice_state):
    """ Calculate the propensity for each event type

    Parameters
    ----------
    kinetic_rates : list
        kinetic rates as defined in sim_parameters.py
    lattice : numpy.ndarray
        current lattice state

    Returns
    ------
    event_propensities : numpy.ndarray
        propensities for each event type


    """

    num_empty_sites = np.count_nonzero(lattice_state == 0)
    num_occupied_sites = np.count_nonzero(lattice_state[:-1] == 1)
    occupied_lattice_end = lattice_state[-1]
    num_forward_hopping_sites = np.count_nonzero(
        (lattice_state[1:] - lattice_state[:-1]) == -1
    )

    event_propensities = np.multiply(
        kinetic_rates,
        [
            num_empty_sites,
            num_occupied_sites,
            occupied_lattice_end,
            num_forward_hopping_sites,
        ],
    )

    return event_propensities


def select_event(propensity_event_type, rand_num):
    """

    Parameters
    ----------
    propensity_event_type : list
        The probability of selecting each event type
    rand_num : numpy.ndarray
        random number from a pre-drawn pool


    Returns
    -------
    event_name : string
        name of the selected event type

    """

    # Construct valid events
    index_valid_events = propensity_event_type > 0
    valid_propensity = propensity_event_type[index_valid_events]

    # Stop current simulation if no valid changes are available
    valid_changes = np.nonzero(index_valid_events)[0]
    any_available_events = len(np.nonzero(index_valid_events)[0] > 0)

    if any_available_events:
        selection_interval = valid_propensity.cumsum()  # Construct intervals
        selection_interval = selection_interval / selection_interval[-1]
        # selected_event = numpy.nonzero(selection_interval > rand_nums[1][counter])[0][0]
        selected_event = np.nonzero(selection_interval > rand_num)[0][0]

        event_name = event_type(valid_changes[selected_event])

        return event_name

    else:
        return None


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
        pos = np.nonzero(lattice_state == 0)[0]
        index = np.random.choice(pos)
        lattice_state[index] += 1

    elif seleted_event == 1:  # Detachment event lattice
        pos = np.nonzero(lattice_state[:-1] == 1)[0]
        index = np.random.choice(pos)
        lattice_state[index] -= 1

    elif seleted_event == 2:  # Detachment event lattice end
        lattice_state[-1] -= 1

    elif seleted_event == 3:  # Forward hopping event
        pos = np.nonzero((lattice_state[1:] - lattice_state[:-1]) == -1)[0]
        index = np.random.choice(pos)
        lattice_state[index] -= 1
        lattice_state[index + 1] += 1

    return lattice_state

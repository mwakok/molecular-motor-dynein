import numpy as np


def propensity(kinetic_rates, lattice_state):
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

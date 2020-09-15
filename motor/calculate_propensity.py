import numpy as np


def propensity(rates, lattice):
    """ Calculate the propensity for each event type

    Parameters
    ----------
    rates : int
        kinetic rates as defined in sim_parameters.py
    lattice : numpy.ndarray
        current lattice state

    Returns
    ------
    pp : numpy.ndarray
        propensities for each event type


    """

    num_event_1 = np.count_nonzero(lattice == 0)  # Empty sites
    num_event_2 = np.count_nonzero(lattice[:-1] == 1)  # Occupied sites
    num_event_3 = lattice[-1]  # Lattice end
    num_event_4 = np.count_nonzero(
        (lattice[1:] - lattice[:-1]) == -1)  # Foward hopping
    pp = np.multiply(
        rates, [num_event_1, num_event_2, num_event_3, num_event_4])

    return pp

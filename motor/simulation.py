import numpy as np
from .calculate_propensity import calculate_propensity
from .update_state import update_state
from .select_event import select_event


def gillespie(simPa):
    """ Run Gillespie algorithm to simulate motor dynamics on microtubules


    Parameters
    ----------
    simPa : 

    Returns
    -------
    collect_lattice : numpy.ndarray

    collect_timepoints : list

    Notes
    -----


    """
    kinetic_rates = [
        simPa.concentration * simPa.k_on,
        simPa.k_off,
        simPa.k_off_end,
        simPa.k_hop,
    ]

    # Initialize simulation counters and output
    counter = 0  # simulation iteration
    elapsed_simulation_time = 0  # time
    lattice_state = np.zeros(simPa.length)  # start simulation with an empty lattice
    collect_lattice_states = []
    collect_timepoints = []
    rand_nums = np.random.rand(2, simPa.iter_max)  # Pre-draw random numbers

    # Run Gillespie simulation until "simPa.time_max"
    while simPa.iter_max > counter and simPa.time_max + 1 > elapsed_simulation_time:

        # Calculate probability for all events
        propensity_event_type = calculate_propensity(kinetic_rates, lattice_state)

        # Draw waiting time
        dt = -np.log(rand_nums[0][counter]) / propensity_event_type.sum()

        selected_event = select_event(propensity_event_type, rand_nums[1][counter])

        if selected_event is None:
            break

        # # Construct valid events
        # valid_inds = propensity_event_type > 0  # Find the possible events
        # valid_pp = propensity_event_type[valid_inds]  # Include only valid events
        # valid_changes = np.nonzero(valid_inds)[0]

        # # Stop current simulation if no valid changes are available
        # if len(valid_changes) == 0:
        #     break

        # selection_interval = valid_pp.cumsum()  # Construct intervals
        # selection_interval = selection_interval / selection_interval[-1]
        # selected_ind = np.nonzero(selection_interval > rand_nums[1][counter])[0][0]

        # Update lattice configuration based on chosen interval
        # lattice_state = update_state(valid_changes[selected_ind], lattice_state)
        lattice_state = update_state(selected_event, lattice_state)

        elapsed_simulation_time += dt
        counter += 1

        # Apply sampling if applicable
        if simPa.frame_time > 0:
            while (
                len(collect_lattice_states)
                < np.floor(elapsed_simulation_time / simPa.frame_time)
                and len(collect_lattice_states) <= simPa.time_max
            ):
                collect_lattice_states.append(lattice_state.copy())
                collect_timepoints.append(elapsed_simulation_time)

    # Collect final state if sampling is off
    if simPa.frame_time == 0:
        collect_lattice_states = lattice_state
        collect_timepoints = elapsed_simulation_time

    return collect_lattice_states, collect_timepoints

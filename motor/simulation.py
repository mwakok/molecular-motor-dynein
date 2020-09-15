import numpy as np
from .calculate_propensity import propensity
from .update_state import update_state


# Monte Carlo simulation based on the Gillespie algorithm
def gillespie(simPa):
    # Extract simulation parameters
    rates = [simPa.concentration*simPa.k_on,
             simPa.k_off, simPa.k_off_end, simPa.k_hop]

    # Initialize simulation counters and output
    counter = 0  # simulation iteration
    tt = 0  # time
    lattice = np.zeros(simPa.length)  # start simulation with an empty lattice
    lattice_cont = []
    tt_cont = []
    rand_nums = np.random.rand(2, simPa.iter_max)   # Pre-draw random numbers

    # Run Gillespie simulation until "simPa.time_max"
    while simPa.iter_max > counter and simPa.time_max+1 > tt:

        pp = propensity(rates, lattice)  # Calculate probability for all events
        delta_t = -np.log(rand_nums[0][counter]) / \
            pp.sum()  # Draw waiting time

        # Construct valid events
        valid_inds = pp > 0  # Find the possible events
        valid_pp = pp[valid_inds]  # Include only valid events
        valid_changes = np.nonzero(valid_inds)[0]

        # Stop current simulation if no valid changes are available
        if len(valid_changes) == 0:
            break

        selection_interval = valid_pp.cumsum()  # Construct intervals
        selection_interval = selection_interval/selection_interval[-1]
        selected_ind = np.nonzero(selection_interval > rand_nums[1][counter])[
            0][0]   # Select interval
        # Update lattice configuration based on chosen interval
        lattice = update_state(valid_changes[selected_ind], lattice)

        tt += delta_t
        counter += 1

        # Apply sampling if applicable
        if simPa.frame_time > 0:
            while len(lattice_cont) < np.floor(tt/simPa.frame_time) and len(lattice_cont) <= simPa.time_max:
                lattice_cont.append(lattice.copy())
                tt_cont.append(tt)

    # Collect final state if sampling is off
    if simPa.frame_time == 0:
        lattice_cont = lattice
        tt_cont = tt

    return lattice_cont, tt_cont

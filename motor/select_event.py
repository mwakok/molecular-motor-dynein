import numpy


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
    selected_event : 



    """

    # Construct valid events
    valid_inds = propensity_event_type > 0  # Find the possible events
    valid_propensity = propensity_event_type[valid_inds]  # Include only valid events

    # Stop current simulation if no valid changes are available
    valid_changes = numpy.nonzero(valid_inds)[0]
    if len(valid_changes) == 0:
        return None
    else:
        selection_interval = valid_propensity.cumsum()  # Construct intervals
        selection_interval = selection_interval / selection_interval[-1]
        # selected_event = numpy.nonzero(selection_interval > rand_nums[1][counter])[0][0]
        selected_event = numpy.nonzero(selection_interval > rand_num)[0][0]
        return selected_event

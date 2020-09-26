import numpy
from motor import event_type


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
    valid_changes = numpy.nonzero(index_valid_events)[0]
    any_available_events = len(numpy.nonzero(index_valid_events)[0] > 0)

    if any_available_events:
        selection_interval = valid_propensity.cumsum()  # Construct intervals
        selection_interval = selection_interval / selection_interval[-1]
        # selected_event = numpy.nonzero(selection_interval > rand_nums[1][counter])[0][0]
        selected_event = numpy.nonzero(selection_interval > rand_num)[0][0]

        event_name = event_type(valid_changes[selected_event])

        return event_name

    else:
        return None

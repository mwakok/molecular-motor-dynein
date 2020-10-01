def event_type(selection):

    events = {0: "attach", 1: "detach", 2: "detach_end", 3: "forward_hop"}

    return events[selection]

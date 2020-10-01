from motor import event_type


def test_event_type_attachment():
    assert event_type(0) == "attach"


def test_event_type_detachment():
    assert event_type(1) == "detach"


def test_event_type_detachment_end():
    assert event_type(2) == "detach_end"


def test_event_type_forward_hop():
    assert event_type(3) == "forward_hop"

from motor import select_event
import numpy


def test_select_event_none():
    propensity_event_type = numpy.array([0, 0, 0, 0])
    rand_num = numpy.random.rand(1)
    event_type = select_event(propensity_event_type, rand_num)
    expected_event_type = None
    assert event_type == expected_event_type


def test_select_event_attach():
    propensity_event_type = numpy.array([1, 0, 0, 0])
    rand_num = numpy.random.rand(1)
    event_type = select_event(propensity_event_type, rand_num)
    expected_event_type = "attach"
    assert event_type == expected_event_type


def test_select_event_detach():
    propensity_event_type = numpy.array([0, 1, 0, 0])
    rand_num = numpy.random.rand(1)
    event_type = select_event(propensity_event_type, rand_num)
    expected_event_type = "detach"
    assert event_type == expected_event_type


def test_select_event_detach_end():
    propensity_event_type = numpy.array([0, 0, 1, 0])
    rand_num = numpy.random.rand(1)
    event_type = select_event(propensity_event_type, rand_num)
    expected_event_type = "detach_end"
    assert event_type == expected_event_type


def test_select_event_forward_hop():
    propensity_event_type = numpy.array([0, 0, 0, 1])
    rand_num = numpy.random.rand(1)
    event_type = select_event(propensity_event_type, rand_num)
    expected_event_type = "forward_hop"
    assert event_type == expected_event_type


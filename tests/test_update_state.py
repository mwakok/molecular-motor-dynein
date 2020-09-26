from motor import update_state
import numpy


def test_update_state_attachment():
    # Test motor landing on lattice
    selected_event = "attach"
    lattice_state = numpy.zeros(5)
    lattice_state_new = update_state(selected_event, lattice_state)
    assert numpy.sum(lattice_state_new) == 1


def test_update_state_detachment():
    # Test motor detachment from lattice
    selected_event = "detach"
    lattice_state = numpy.ones(5)
    lattice_state_new = update_state(selected_event, lattice_state)
    assert numpy.sum(lattice_state_new) == 4


def test_update_state_detachment_end():
    # Test motor detachment of lattice end
    selected_event = "detach_end"
    lattice_state = numpy.ones(5)
    lattice_state_new = update_state(selected_event, lattice_state)
    expected_lattice = numpy.append(numpy.ones(4), 0)
    assert numpy.all(lattice_state_new == expected_lattice)


def test_update_state_forward_hopping():
    # Test forward hopping on lattice
    selected_event = "forward_hop"
    lattice_state = numpy.array([1, 0, 0, 0, 0])
    lattice_state_new = update_state(selected_event, lattice_state)
    expected_lattice = numpy.array([0, 1, 0, 0, 0])
    assert numpy.all(lattice_state_new == expected_lattice)


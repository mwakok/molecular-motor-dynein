from motor import calculate_propensity
import numpy


def test_calculate_propensity_empty_lattice():
    lattice_state = numpy.zeros(10)
    kinetic_rates = numpy.ones(4)
    event_propensities = calculate_propensity(kinetic_rates, lattice_state)
    expected_propensities = [10, 0, 0, 0]
    assert numpy.all(event_propensities == expected_propensities)


def test_calculate_propensity_full_lattice():
    lattice_state = numpy.ones(10)
    kinetic_rates = numpy.ones(4)
    event_propensities = calculate_propensity(kinetic_rates, lattice_state)
    expected_propensities = [0, 9, 1, 0]
    assert numpy.all(event_propensities == expected_propensities)


def test_calculate_propensity_mixed_lattice():
    lattice_state = numpy.array([0, 1, 1, 0, 1, 1, 0, 0, 1, 1])
    kinetic_rates = numpy.ones(4) * 2
    event_propensities = calculate_propensity(kinetic_rates, lattice_state)
    expected_propensities = [8, 10, 2, 4]
    assert numpy.all(event_propensities == expected_propensities)


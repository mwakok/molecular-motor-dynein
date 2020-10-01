import numpy as np

from motor import simulation
from motor import gillespie
from parameters import ParameterSet


simParameters = {
    "record_data": False,
    "num_sims": 1,
    "scan": False,
    "concentration": 1,
    "step_size": 24,
    "length": 100,
    "length_range": np.arange(40, 301, 10),
    "iter_max": 100000,
    "time_max": 300,
    "frame_time": 0,
    "k_on": 1,
    "k_off": 1,
    "k_off_end": 0,
    "k_hop": 0,
}
simPa = ParameterSet(simParameters)


def test_gillespie_break():
    # Test the response of the simulation if all event propensities become zero
    simPa = ParameterSet(simParameters)
    simPa.k_off = 0
    [lattice, _] = gillespie(simPa)
    expected_lattice = np.ones(simPa.length)
    assert np.all(lattice == expected_lattice)


def test_gillespie_max_time():
    # Test break simulation on maximum simulation time (not run time!)
    simPa = ParameterSet(simParameters)
    simPa.time_max = 10
    [_, time] = gillespie(simPa)
    assert time >= simPa.time_max


def test_gillespie_max_iterations():
    # Test break simulation on maximum iterations
    simPa = ParameterSet(simParameters)
    simPa.iter_max = 100
    [_, time] = gillespie(simPa)
    expected_time = simPa.time_max
    assert time <= expected_time

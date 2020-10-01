import numpy as np


# Dictionary to store all simulation parameters

simParameters = {
    "record_data": False,  # Store data and figures: True or False
    "num_sims": 200,  # Number of simulations per scan condition
    "scan": False,  # True (vary lattice size) or False
    "type": "SP",  # Determine type of dynein: 'WT' (Wild-Type) or 'SP' (Super-Processive)
    "concentration": 2.5,  # Dynein concentration in nM
    "step_size": 24,  # Basic lattice unit is size of motor step, for dynein the step size is 24 nm
    "length": 100,  # Length lattice in hopping units
    "length_range": np.arange(40, 301, 10),  # length range to scan
    "iter_max": 100000,  # Maximum number of iterations per condition
    "time_max": 300,  # Max simulated time (in seconds)
    # Frame time to sample the lattice configuration (in seconds).
    # If 0, then only the final state will be saved and no kymographs will be generated
    "frame_time": 1,
}

if simParameters["type"] == "WT":  # Wild-type dynein
    simParameters["k_on"] = 0.0025  # Attachment rate [/nM/sec]
    simParameters["k_off"] = 73.9 / 2250  # Detachment rate bulk [/sec]
    # Forward hopping rate [sites/sec]
    simParameters["k_hop"] = 73.9 / simParameters["step_size"]
    # Detachment rate end lattice [/sec]
    simParameters["k_off_end"] = simParameters["k_off"]

elif simParameters["type"] == "SP":  # Super processive dynein
    simParameters["k_on"] = 0.0025  # Attachment rate [/nM/sec]
    simParameters["k_off"] = 60.6 / 4390  # Detachment rate bulk [/sec]
    # Forward hopping rate [sites/sec]
    simParameters["k_hop"] = 60.6 / simParameters["step_size"]
    # Detachment rate end lattice [/sec]
    simParameters["k_off_end"] = simParameters["k_off"]

elif simParameters["type"] == "User":  # User specified settings
    simParameters["k_on"] = 1  # Attachment rate [/nM/sec]
    simParameters["k_off"] = 1  # Detachment rate bulk [/sec]
    # Forward hopping rate [sites/sec]
    simParameters["k_hop"] = 0 / simParameters["step_size"]
    # Detachment rate end lattice [/sec]
    simParameters["k_off_end"] = 1
import numpy


# Dictionary to store all simulation parameters

simParameters = {
    
# Store data and figures: True or False
"record_data": False,
"num_sims": 200,  # Number of simulations per scan condition
"scan": False,  # True (vary lattice size) or False

# Determine type of dynein: 'WT' (Wild-Type) or 'SP' (Super-Processive)
"type": "SP",
"concentration": 2.5 , # Dynein concentration in nM

# Basic lattice unit is size of motor step, for dynein the step size is 24 nm
"step_size": 24,
"length": 100, # Length lattice in hopping units
"length_range": numpy.arange(40, 301, 10),  # length range to scan

# Maximum number of iterations per condition
"iter_max": 100000,
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


# Simulation of molecular motor dynamics on microtubules

## Work done by:
* Simulation code: Maurits Kok
* Experiments and theory: Louis Reese

## Abstract
The precise localization of proteins is key to understand biological functions and to quantify protein interactions. Microtubule related motor proteins consume ATP to move along microtubules and often localize at microtubule tips. Whereas molecular motors have been studied extensively in terms of run-lengths and dwell times on the single molecule level, a quantitative understanding of the accumulation of motors on microtubules is still lacking. Here we develop a high-throughput microscopy strategy to accurately determine the distribution of motors on microtubules. By imaging an ensemble of microtubules with motors, datasets are obtained which allow to quantify parameters of a minimal model for the microtubule-motor system. The approach bypasses typical constraints of fluorescence imaging such as bleaching and small sample sizes. As a proof of principle we study quantitatively study the length-dependent accumulation of motors for the case of a yeast dynein.

## Simulation
To understand the experimentally measured motor protein profiles, we use a simple Gilliespie algorithm to simulate the motion of yeast dynein on a 1D lattice. The simulation and analysis can be found in separate Jupyter Notebooks.

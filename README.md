## CABLE Trait Acclimation

This repository contains the source code, experiment settings, and pre-processing scripts used in our study of coordinated leaf trait acclimation and its effects on simulated photosynthetic sensitivity to elevated CO2 in the CABLE land surface model.

### Main contents

- `0_data/`:
    Compiled trait datasets used in the analysis.
- `control/`:
    Model control files and experiment setup for different CO2 scenarios.
    - `CABLE2.0/`: the CABLE source code (`CABLE2.0/core/`) and compile file (`CABLE2.0/offline/`)
    - `Run_1CO2_CK/`: configuration settings and running script under aCO2
    - `Run_2CO2_CK/`: configuration settings and running script under eCO2
- `rand_acc/`, `rand_acc_cov/`, `rand_acc_cov_aco2/`:
    Modified model code and experiment folders for different acclimation configurations.
    - `rand_acc/`: acclimation-only under eCO2;
    - `rand_acc_cov/`: acclimation + Coordination under eCO2;
    - `rand_acc_cov_aco2/`: acclimation + Coordination under aCO2
- `src/`:
    Scripts for data preprocessing, variable extraction, and analysis.

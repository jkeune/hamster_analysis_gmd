# hamster_analysis_gmd
This repository contains the analysis scripts for the GMD manuscript "A holistic framework to estimate the origins of atmospheric moisture and heat using a Lagrangian model" by Jessica Keune, Dominik L. Schumacher and Diego G. Miralles (Hydro-Climate Extremes Laboratory, Ghent University, Belgium). The analysis is based on the output of the 'Heat And MoiSture Tracking framEwoRk' (HAMSTER), available via https://github.com/h-cel/hamster. 

- - - -
## Description of this repository

The following section briefly describes the data required to run the analysis and the workflow. 

### Data 
The analysis is based on three types of data sets: 
1. **FLEXPART-ERA-Interim simulations.** Due to the large amount of data (>30TB in a compressed format), this data is only available upon request. The output of these simulations is used to run 'HAMSTER' (https://github.com/h-cel/hamster). Details on the setting of HAMSTER are described in the Supplementary Material of the manuscript and in `SETUPS_experiments.txt`.
2. **Outputs of HAMSTER.** The post-processed outputs from HAMSTER are available on Zenodo: These data sets are required to create the figures embedded in the manuscript.  
3. **Reference and static data sets.** Additional data sets, such as ERA-Interim for the validation, and geographic data, such as coastlines for plotting, are required. Scripts to download these data sets are available in `.data/erainterim` and `./data/staticdata`. 

### Scripts
The scripts in this repository contain all scripts required to perform the analysis in the GMD manuscript. For running HAMSTER, please see requirements detailed in the repository. The remaining scripts are python and R-scripts, for which the required packages are listed at the top of each script. 

The workflow is as follows: 
```bash
./00_get_hamster.sh
```
This script will clone the HAMSTER software from https://github.com/h-cel/hamster.
```bash
Rscript 01_create_city_mask.r 
```
This script creates a global netcdf file with a mask that indicates the cities Denver (mask value 1001), Beijing (mask value 3001) and Windhoek (mask value 5002). This netcdf file is used to run HAMSTER. 

The scripts
```bash
./02_run_flex2traj.sh
./03_run_hamster.sh
./04_run_postpro.sh
```
use output from the global FLEXPART-ERA-Interim simulations to (i) extract trajectories (both two-step trajectories for the global diagnosis, and 16-day trajectories for the three cities), then to (ii) perform the analysis for all setups/experiments listed in `SETUPS_experiments.txt`, and (iii) post-process the monthly output files for better handling. 

The script 
```
./05_postpro_eraint.sh
```
post-processes the ERA-Interim data accordingly. Scripts to download ERA-Interim are available in `./data/erainterim`. 

The global validation of fluxes estimated with HAMSTER from FLEXPART-ERA-Interim simulations is performed with
```bash
python 06_validation_stats_global.py
```
and uses the post-processed outputs from the previous steps. 

The post-processed outputs and the validation files are available via Zenodo: XXXX. 

The figures of the manuscript are created using R and use the above mentioned post-processed outputs: 
```bash
Rscript 11_validation_maps_all.r
Rscript 12_validation_plots_pod.r
Rscript 13_E2P_maps.r
Rscript 14_E2P_relative_contributions.r
Rscript 15_Had_maps.r
Rscript 16_Had_relative_contributions.r
Rscript 17_Had_origin.r
Rscript 18_E2P_origin.r
```

Some scripts require additional geographical data sets for plotting (i.e., coastlines). The corresponding scripts to download these data sets are available in  
````bash
./data/staticdata
```

- - - -
### Contact and support
Jessica Keune (jessica.keune@ugent.be)

### References
If you use scripts or data from this repository in a publication, please add a link to this repository to the Acknowledgements and cite the following references:
- Keune, J., D. L. Schumacher, D. G. Miralles: A holistic framework to estimate the origins of atmospheric moisture and heat using a Lagrangian model.
- Keune, J., D. L. Schumacher, D. G. Miralles: Datasets for "A holistic framework to estimate the origins of atmospheric moisture and heat using a Lagrangian model", Zenodo. 

### License
Copyright 2021 Jessica Keune, Dominik L. Schumacher, Diego G. Miralles. 

This software is published under the GPLv3 license. This means: 
1. Anyone can copy, modify and distribute this software. 
2. You have to include the license and copyright notice with each and every distribution.
3. You can use this software privately.
4. You can use this software for commercial purposes.
5. If you dare build your business solely from this code, you risk open-sourcing the whole code base.
6. If you modify it, you have to indicate changes made to the code.
7. Any modifications of this code base MUST be distributed with the same license, GPLv3.
8. This software is provided without warranty.
9. The software author or license can not be held liable for any damages inflicted by the software.

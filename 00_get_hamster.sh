#!/bin/bash

# clone latest version of hamster
git clone https://github.com/h-cel/hamster
# optional: additionally swap to v1.2.0 
# git clone --branch v1.2.0 https://github.com/h-cel/hamster

# move paths_*.txt and other files needed to run hamster to hamster/src directory
mv hamster_supplement/* hamster/src/.
mv SETUPS_experiments.txt hamster/src/SETUPS_experiments.txt

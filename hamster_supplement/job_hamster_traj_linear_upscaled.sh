#!/bin/bash -l

#PBS -S /usr/bin/bash
#PBS -N hamster
#PBS -l nodes=1:ppn=1
#PBS -l walltime=01:00:00
#PBS -l mem=20GB
#PBS -m bea

set -e
set -u
set -x

ml netcdf4-python/1.5.3-intel-2019b-Python-3.7.4

# SETTINGS
yyyy=${PBS_ARRAYID}
pyyyy=$((${yyyy}-1))

for mm in `seq 1 1 12`;
do

        echo "************************************"
        echo "PROCESSING STEP 2: ATTRIBUTION"
        echo "************************************"

        time python main.py --steps 2 --ayyyy ${yyyy} --ryyyy ${yyyy} --am $mm \
                                 --expid $expid \
                                 --pathfile $pathfile \
                                 --cpbl_strict $cpbl_strict --cpbl_method $cpbl_method --cpbl_factor $cpbl_factor \
                                 --cheat_dtemp $cheat_dtemp --fheat_drh $fheat_drh --cheat_drh $cheat_drh --fheat_rdq $fheat_rdq --cheat_rdq $cheat_rdq \
                                 --cevap_dqv $cevap_dqv --fevap_drh $fevap_drh --cevap_drh $cevap_drh \
                                 --ctraj_len 15 \
                                 --maskval $mval \
                                 --explainp full --mupscale True --dupscale True \
                                 --writestats True

        echo "************************************"
        echo "PROCESSING STEP 3: BIAS CORRECTION"
        echo "************************************"

        time python main.py --steps 3 --ayyyy ${yyyy} --ryyyy ${yyyy} --am $mm \
                                 --expid $expid \
                                 --pathfile $pathfile \
                                 --maskval $mval \
                                 --bc_useattp True --bc_aggbwtime False \
                                 --writestats True

done

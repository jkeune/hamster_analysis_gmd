#!/bin/bash -l

#PBS -S /usr/bin/bash
#PBS -N hamster
#PBS -l nodes=1:ppn=1
#PBS -l walltime=12:00:00
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

   # hamster diagnosis
   time python main.py --steps 1 --ayyyy ${yyyy} --ryyyy ${yyyy} --am $mm \
                                 --expid $expid \
                                 --pathfile $pathfile \
                                 --cpbl_strict $cpbl_strict --cpbl_method $cpbl_method --cpbl_factor $cpbl_factor \
                                 --cheat_dtemp $cheat_dtemp --fheat_drh $fheat_drh --cheat_drh $cheat_drh --fheat_rdq $fheat_rdq --cheat_rdq $cheat_rdq \
                                 --cevap_dqv $cevap_dqv --fevap_drh $fevap_drh --cevap_drh $cevap_drh --fproc_npart False

   # also perform previous December (need E and H for bias-correction of source)
   if [ "$mm" == "1" ];
   then

        # hamster diagnosis
        time python main.py --steps 1 --ayyyy ${pyyyy} --ryyyy ${yyyy} --am 12 \
                                 --expid $expid \
                                 --pathfile $pathfile \
                                 --cpbl_strict $cpbl_strict --cpbl_method $cpbl_method --cpbl_factor $cpbl_factor \
                                 --cheat_dtemp $cheat_dtemp --fheat_drh $fheat_drh --cheat_drh $cheat_drh --fheat_rdq $fheat_rdq --cheat_rdq $cheat_rdq \
                                 --cevap_dqv $cevap_dqv --fevap_drh $fevap_drh --cevap_drh $cevap_drh --fproc_npart False
        
   fi

done

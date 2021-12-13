#!/bin/bash

cd hamster/src

#settings: 
syyyy=1980
eyyyy=2016

#----------------------------
## -- (1) global diagnosis --
#----------------------------
pfile="paths_global.txt"
## LOOP OVER SETUPS LISTED IN SETUPS_pblcheck.txt
input="SETUPS_experiments.txt"
{
read # to skip the header line of input
while IFS= read -r line
do
    # extract parameters (separated by white space -d ' ')
    expid=$(echo $line | cut -f1 -d ' ')
    cpbl_strict=$(echo $line | cut -f2 -d ' ')
    cpbl_method=$(echo $line | cut -f3 -d ' ')
    cpbl_factor=$(echo $line | cut -f4 -d ' ')
    cheat_dtemp=$(echo $line | cut -f5 -d ' ')
    fheat_drh=$(echo $line | cut -f6 -d ' ')
    cheat_drh=$(echo $line | cut -f7 -d ' ')
    fheat_rdq=$(echo $line | cut -f8 -d ' ')
    cheat_rdq=$(echo $line | cut -f9 -d ' ')
    cevap_dqv=$(echo $line | cut -f10 -d ' ')
    fevap_drh=$(echo $line | cut -f11 -d ' ')
    cevap_drh=$(echo $line | cut -f12 -d ' ')

    isettings="expid=$expid,pathfile=$pfile,"
    isettings+="cpbl_strict=$cpbl_strict,cpbl_method=$cpbl_method,cpbl_factor=$cpbl_factor,"
    isettings+="cheat_dtemp=$cheat_dtemp,fheat_drh=$fheat_drh,cheat_drh=$cheat_drh,fheat_rdq=$fheat_rdq,cheat_rdq=$cheat_rdq,"
    isettings+="cevap_dqv=$cevap_dqv,fevap_drh=$fevap_drh,cevap_drh=$cevap_drh"
 
    echo " " 
    echo "*** JOB SUBMISSION: $expid" 
    qsub -t $syyyy-$eyyyy -v $isettings job_hamster_diag.sh

done
} < "$input"

#----------------------------
## -- (2) trajectory analysis
#----------------------------
# LOOP OVER SETUPS LISTED IN SETUPS_*.txt
input="SETUPS_experiments.txt"
{
read # to skip the header line of input
while IFS= read -r line
do
    # extract parameters (separated by white space -d ' ')
    expid=$(echo $line | cut -f1 -d ' ')
    cpbl_strict=$(echo $line | cut -f2 -d ' ')
    cpbl_method=$(echo $line | cut -f3 -d ' ')
    cpbl_factor=$(echo $line | cut -f4 -d ' ')
    cheat_dtemp=$(echo $line | cut -f5 -d ' ')
    fheat_drh=$(echo $line | cut -f6 -d ' ')
    cheat_drh=$(echo $line | cut -f7 -d ' ')
    fheat_rdq=$(echo $line | cut -f8 -d ' ')
    cheat_rdq=$(echo $line | cut -f9 -d ' ')
    cevap_dqv=$(echo $line | cut -f10 -d ' ')
    fevap_drh=$(echo $line | cut -f11 -d ' ')
    cevap_drh=$(echo $line | cut -f12 -d ' ')

    isettings="expid=$expid,"
    isettings+="cpbl_strict=$cpbl_strict,cpbl_method=$cpbl_method,cpbl_factor=$cpbl_factor,"
    isettings+="cheat_dtemp=$cheat_dtemp,fheat_drh=$fheat_drh,cheat_drh=$cheat_drh,fheat_rdq=$fheat_rdq,cheat_rdq=$cheat_rdq,"
    isettings+="cevap_dqv=$cevap_dqv,fevap_drh=$fevap_drh,cevap_drh=$cevap_drh"
 
    for icity in 1001 3001 5002;
    do
        echo "*** JOB SUBMISSION: $icity -- $expid" 

        echo "    * linear, no upscaling"
        pfile="paths_${icity}_linear.txt"
        qsub -t $syyyy-$eyyyy -v $isettings,mval=$icity,pathfile=$pfile job_hamster_traj_linear.sh

        echo "    * linear, upscaling"
        pfile="paths_${icity}_linear_upscaled.txt"
        qsub -t $syyyy-$eyyyy -v $isettings,mval=$icity,pathfile=$pfile job_hamster_traj_linear_upscaled.sh

        echo "    * random, upscaling"
        pfile="paths_${icity}_random_upscaled.txt"
        qsub -t $syyyy-$eyyyy -v $isettings,mval=$icity,pathfile=$pfile job_hamster_traj_random_upscaled.sh

    done

done
} < "$input"


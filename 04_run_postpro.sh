#!/bin/bash

#----------------------------
## -- (1) global diagnosis --
#----------------------------
## LOOP OVER SETUPS LISTED IN SETUPS_diagnosis.txt
input="hamster/SETUPS_diagnosis.txt"
{
read # to skip the header line of input
while IFS= read -r line
do
    # extract parameters (separated by white space -d ' ')
    expid=$(echo $line | cut -f1 -d ' ')
 
    echo " " 
    echo "*** JOB SUBMISSION: $expid" 
    
    declare -a nvars=("P" "P_n_part" "E" "E_n_part" "H" "H_n_part")

    for ivar in ${nvars[@]};
    do 
        echo "  -- $ivar"
        qsub -v expid=$expid,process_diag_data=TRUE,process_traj_data=FALSE,ivar=$ivar 04_postpro_hamster.sh
        echo " " 
        sleep 30 # sleep between experiments to avoid simultaneous reading of the same files 
    done
    
    i=$((i+1))

done
} < "$input"

#----------------------------
## -- (2) trajectory analysis
#----------------------------
# LOOP OVER SETUPS LISTED IN SETUPS_diagnosis.txt
input="hamster/SETUPS_diagnosis.txt"
{
read # to skip the header line of input
while IFS= read -r line
do
    # extract parameters (separated by white space -d ' ')
    expid=$(echo $line | cut -f1 -d ' ')

    for icity in 1001 3001 5002;
    do
        echo "*** JOB SUBMISSION: $icity -- $expid" 

        echo "    * linear, no upscaling"
        qsub -v expid=$expid,process_diag_data=FALSE,process_traj_data=TRUE,icity=$icity,iexp="linear" 04_postpro_hamster.sh
        sleep 5

        echo "    * linear, upscaling"
        qsub -v expid=$expid,process_diag_data=FALSE,process_traj_data=TRUE,icity=$icity,iexp="linear_upscaled" 04_postpro_hamster.sh
        sleep 5

        echo "    * random, upscaling"
        qsub -v expid=$expid,process_diag_data=FALSE,process_traj_data=TRUE,icity=$icity,iexp="random2_upscaled" 04_postpro_hamster.sh
        sleep 5

    done

done
} < "$input"

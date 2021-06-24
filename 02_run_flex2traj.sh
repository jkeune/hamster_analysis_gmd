#!/bin/bash

cd hamster/src

## (1) extract global diagnosis data (2 timesteps)

pfile="paths_global.txt"
odir="./data/hamster/global/orig"

for yyyy in `seq 1980 2016`; do

	pyyyy=$((${yyyy}-1))
	
	for m in `seq 1 1 12`;
	do
	
	    echo $yyyy $m
	
	    echo " ** GETTING ARCHIVE... (current + previous month)"
	    ./untar_flexpart_yyyymm.sh $yyyy $m $odir
	
	    echo " ** FLEX2TRAJ... (extracting trajectories)"
	    time python main.py --steps 0 --ayyyy ${yyyy} --ryyyy ${yyyy} --am $m --ctraj_len 0 --pathfile $pfile
	
	    echo " ** CLEANING UP... "
	    rm -rf ${odir}/${yyyy}/*
	
	done
	
done

## (2) extract trajectories (16 days) for the three cities
for icity in 1001 3001 5002;
do
        echo $icity

	# SETTINGS
	pfile="paths_${mval}_linear.txt"
	odir=".data/hamster/${mval}/orig"
	for yyyy in `seq 1980 2016`;
	do

		pyyyy=$((${yyyy}-1))

		for m in `seq 1 1 12`;
		do
		
		    echo $mval $yyyy $m
		
		    echo " ** GETTING ARCHIVE... (current + previous month)"
		    ./untar_flexpart_yyyymm.sh $yyyy $m $odir
		
		    echo " ** FLEX2TRAJ... (extracting trajectories)"
		    time python main.py --steps 0 --ayyyy ${yyyy} --ryyyy ${yyyy} --am $m --ctraj_len 16 --maskval $mval --pathfile $pfile
		
		    echo " ** CLEANING UP... "
		    rm -rf ${odir}/${yyyy}/*
		
		done
	
	done

done

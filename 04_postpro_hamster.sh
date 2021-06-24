#!/bin/bash -l

module load CDO/1.9.8-intel-2019b

## settings
expid=$1
icity=$2 
iexp=$3
ivar=$4

## post-process monthly outputs:
# (i) diagnosis data

ipath="./data/diagnosis/1x1"
hpath="./data"    
opath="${hpath}/postpro/global"
if [ ! -d "$opath" ]; then mkdir -p $opath; fi
   
# calculate daily sums/means for each monthly nc-file; handle NAs etc. 
./calc_daily_data_diag.sh $expid $ipath $opath $ivar
# merge all months into *_all.nc files; and calculate *_mean.nc and *_ymean.nc
./merge_and_mean_hamster_diag.sh $expid $opath $ivar
    

## (ii) bias-corrected attribution data

hpath="./data"    
ipath="${hpath}/${icity}/03_bias/${iexp}"
opath="${hpath}/postpro/${icity}/${iexp}"
if [ ! -d "opath" ]; then mkdir -p $opath; fi
    
echo ""
echo "PROCESSING ${expid}..."
        
echo " "
echo "./merge_and_mean_hamster_traj.sh $expid $ipath 1980 2016"
./merge_and_mean_hamster_traj.sh $expid $ipath 1980 2016

# mean: merge years
ofile="${opath}/${icity}_biascor-attr_${expid}_${iexp}_1980-2016_mean.nc"
cdo -O -b F64 -timavg -mergetime ${ipath}/${expid}_biascor-attr_*_mean.nc ${ofile}

# bwmean: merge years
ofile="${opath}/${icity}_biascor-attr_${expid}_${iexp}_1980-2016_bwmean.nc"
cdo -O -b F64 -timavg -mergetime ${ipath}/${expid}_biascor-attr_*_bwmean.nc ${ofile}


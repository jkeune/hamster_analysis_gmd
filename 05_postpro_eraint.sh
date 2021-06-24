#!/bin/bash

module load CDO/1.9.8-intel-2019b

# input path
epath="./data/erainterim"

# output path (on scratch due to storage limits on data)
spath="./data/erainterim/postpro"
if [ ! -d "$spath" ]; then mkdir -p $spath; fi

# aggregating ERA-Interim output to daily
for iyyyy in `seq 1980 2016`;
do
    for ivar in H E P;
    do
        
        echo $ivar $iyyyy
        nyyyy=$(($iyyyy+1))

        if [ "$ivar" = "P" ]; then
            ipath="$epath/tp_12hourly"
            # convert from m to mm; removing negative values
            cdo -O -b F64 -setmissval,nan -setattribute,P_ERA@units="mm" -mulc,1000 -timselsum,2 -chname,"tp","P_ERA" -setrtoc,-10000,0,0 ${ipath}/${ivar}_1deg_${iyyyy}.nc $spath/${ivar}_ERA_1deg_${iyyyy}_daysum.nc
        fi
        if [ "$ivar" = "E" ]; then
            ipath="$epath/evap_12hourly"
            # convert from m to mm; converting upward flux (-1 --> 1) removing (originally) positive values
            cdo -O -b F64 -setmissval,nan -setattribute,E_ERA@units="mm" -mulc,-1000 -timselsum,2 -chname,"e","E_ERA" -setrtoc,0,1e99,0 ${ipath}/${ivar}_1deg_${iyyyy}.nc $spath/${ivar}_ERA_1deg_${iyyyy}_daysum.nc
        fi    
        if [ "$ivar" = "H" ]; then
            ipath="$epath/sshf_12hourly"
            jm2towm2=0.00001157407407 # to convert from J m-2 to W m-2 (=1/(24*3600)) # only valid for daily data
            # in addition setting all (originally) positive values to 0
            cdo -O -b F64 -setmissval,nan -setattribute,H_ERA@units="W m-2" -mulc,-1 -mulc,$jm2towm2 -timselmean,2 -setrtoc,0,1e99,0 -chname,"sshf","H_ERA" ${ipath}/${ivar}_1deg_${iyyyy}.nc $spath/${ivar}_ERA_1deg_${iyyyy}-${imm}_daymean.nc
        fi    

    done
done

# final files (daily data)
for ivar in E P H; 
do
    if [ "${ivar}" == "H" ]; then iavg="daymean"; else iavg="daysum"; fi

    # *_all.nc
    # adding sellonlatbox to shift 0...360 to -180...180 grid; following https://code.mpimet.mpg.de/boards/1/topics/22
    ofile="$spath/${ivar}_ERA_1deg_${iavg}_1980-2016_all.nc"
    cdo -invertlat -sellonlatbox,-180,180,-90,90 -mergetime "$spath/${ivar}_ERA_1deg_*_${iavg}.nc" $ofile

    # time means
    ofile2="$spath/${ivar}_ERA_1deg_${iavg}_1980-2016_mean.nc"
    cdo timmean $ofile $ofile2

    # year means
    ofile3="$spath/${ivar}_ERA_1deg_${iavg}_1980-2016_ymean.nc"
    cdo timmean $ofile $ofile3

done

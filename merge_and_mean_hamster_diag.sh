#!/bin/bash

expid=$1
opath=$2
ivar=$3

echo " "
echo "*** ${expid} ***"

    echo $ivar
    if [ "${ivar}" == "H" ]; then iavg="daymean"; else iavg="daysum"; fi

    # final files (*all.nc)
    afile="$opath/${ivar}_${expid}_${iavg}_1980-2016_all.nc"
    cdo -O -b F64 mergetime "$opath/${ivar}_${expid}_*-*_${iavg}.nc" $afile

    # time means
    cdo -O -b F64 timmean $afile "$opath/${ivar}_${expid}_${iavg}_1980-2016_mean.nc"
    # year means
    cdo -O -b F64 yearmean $afile "$opath/${ivar}_${expid}_${iavg}_1980-2016_ymean.nc"


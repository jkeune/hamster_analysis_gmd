#!/bin/bash

### settings
expid=$1
ipath=$2
opath=$3
ivar=$4
syyyy=1980
eyyyy=2016


# -- main
for iyyyy in `seq $syyyy $eyyyy`;
do
    for im in `seq 1 12`;
    do
        imm=$(printf "%02d" $im)
        iyy=${iyyyy: -2}

        echo $iyyyy $imm
        
        if [ "${ivar}" == "H" ]; then 
            iavg="daymean"
            ofile="${opath}/${ivar}_${expid}_diag_r${iyy}_${iyyyy}-${imm}_${iavg}.nc"
            cdo -O -b F64 -timselmean,4 -selvar,$ivar -setrtomiss,1e20,1e999 -setmissval,nan ${ipath}/${expid}_diag_r${iyy}_${iyyyy}-${imm}.nc $ofile
        else
            iavg="daysum"
            ofile="${opath}/${ivar}_${expid}_diag_r${iyy}_${iyyyy}-${imm}_${iavg}.nc"
            cdo -O -b F64 -timselsum,4 -selvar,$ivar -setrtomiss,1e20,1e999 -setmissval,nan ${ipath}/${expid}_diag_r${iyy}_${iyyyy}-${imm}.nc $ofile
        fi

    done
done


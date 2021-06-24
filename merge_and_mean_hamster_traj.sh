#/bin/bash

### settings
expid=$1
ipath=$2
syyyy=1980
eyyyy=2016

for iyyyy in `seq $syyyy $eyyyy`; 
do
    
    echo " * ${iyyyy}"
    iyy2=${iyyyy: -2}

    # output files 
    afile="${ipath}/${expid}_biascor-attr_${iyyyy}_all.nc"
    mfile="${ipath}/${expid}_biascor-attr_${iyyyy}_mean.nc"
    bfile="${ipath}/${expid}_biascor-attr_${iyyyy}_bwmean.nc"
    if [ -f "${afile}" ]; then rm "${afile}"; fi
    if [ -f "${mfile}" ]; then rm "${mfile}"; fi
    if [ -f "${bfile}" ]; then rm "${bfile}"; fi

    # time merger
    echo "cdo -O -b F64 mergetime ${ipath}/${expid}_biascor-attr_r*{iyyyy}*.nc ${afile}"
    cdo -O -b F64 mergetime ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-01.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-02.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-03.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-04.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-05.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-06.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-07.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-08.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-09.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-10.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-11.nc ${ipath}/${expid}_biascor-attr_r${iyy2}_${iyyyy}-12.nc ${afile}
    echo "Successfully created: ${afile}"
    echo " "

    # average source region
    echo "cdo -O -b F64 -timavg -vertsum -setmisstoc,0 -setmissval,nan -setrtomiss,1e+36,1e+40 ${afile} ${mfile}"
    cdo -O -b F64 -timavg -vertsum -setmisstoc,0 -setmissval,nan -setrtomiss,1e+36,1e+40 $afile $mfile
    echo "Successfully created: ${mfile}"
    echo " "

    # relative backward day contribution 
    echo "cdo -O -b F64 -timavg -setmisstoc,0 -setmissval,nan -setrtomiss,1e+36,1e+40 ${afile} ${bfile}"
    cdo -O -b F64 -timavg -setmisstoc,0 -setmissval,nan -setrtomiss,1e+36,1e+40 $afile $bfile
    echo "Successfully created: ${bfile}"

    # remove *all.nc file to avoid storage issues (only needed to get *mean.nc and *bwmean.nc)
    rm $afile

done

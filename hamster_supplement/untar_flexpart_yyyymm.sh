#!/bin/bash
# Usage: ./untar_flexpart_yyyymm.sh YYYY MM PATH
# JKe 06/2018
# untars current + previous month

# DATES to be processed
  yyyy=$1                               # YYYY (2010)
  yy=${yyyy: -2}                        # YY   (10)
  m=$2
  mm=$(printf "%02d" $m)
  # previous month
  if [[ $m == "1" ]]; then
      pm=12
      pmm=12
      pyyyy=$(($yyyy-1))                    # previous year YYYY (2009)
      pyy=${pyyyy: -2}                      # previous year YY (09)
  else    
      pm=$(($m-1))
      pmm=$(printf "%02d" $pm)
      pyyyy=$yyyy
      pyy=${yyyy: -2}
  fi    
  # next month
  nm=$(($m+1))
  nmm=$(printf "%02d" $nm)

  # PATHS
  tardir="./data/flexpart/era_global"
  workdir=$3
  outdir="${workdir}/${yyyy}"
  if [ ! -d $outdir ]; then mkdir -p $outdir; fi

  # FILENAMES
    # if yy in 13,14,15,16,17 use directory outflex_int${yy}_new
    if [[ "$yy" =~ ^(13|14|15|16|17)$ ]]; then
      tarfile="${tardir}/outflex_int${yy}_new/archived_partposit_${yyyy}${mm}.tar"
      ptarfile="${tardir}/outflex_int${yy}_new/archived_partposit_${pyyyy}${pmm}.tar"
      ntarfile="${tardir}/outflex_int${yy}_new/archived_partposit_${yyyy}${nmm}.tar"
    else
      tarfile="${tardir}/outflex_int${yy}/archived_partposit_${yyyy}${mm}.tar"
      ptarfile="${tardir}/outflex_int${yy}/archived_partposit_${pyyyy}${pmm}.tar"
      ntarfile="${tardir}/outflex_int${yy}/archived_partposit_${yyyy}${nmm}.tar"
    fi

  # UNTAR
    # current month
    echo "tar -C $outdir -xvf $tarfile"
    tar -C $outdir -xvf $tarfile
    echo "Successfully extracted FLEXPART DATA for ${yyyy}-${mm}"
        
    # previous month
    echo "tar -C $outdir -xvf $ptarfile" 
    tar -C $outdir -xvf $ptarfile
    echo "Successfully extracted FLEXPART DATA for ${pyyyy}-${pmm}"

    # next month, first day...
    if [[ "$nm" -lt "13" ]];
    then 
        nfile="partposit_${yyyy}${nmm}01000000.gz"
        echo "tar -C $outdir -xvf $ntarfile" 
        tar -C $outdir -xvf $ntarfile $nfile
        echo "Successfully extracted FLEXPART DATA for ${yyyy}-${nmm}"
    fi

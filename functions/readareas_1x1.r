readareas_1x1 = function(ifile="staticdata/areas_1x1.nc"){

    ncfile  = nc_open(ifile)
    areas   = ncvar_get(ncfile,"area")
    areas[which(areas=="NaN")]=0

return(areas)}

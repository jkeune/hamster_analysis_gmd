
# module load R/3.4.4-intel-2018a-X11-20180131

Sys.setenv(TZ='GMT')
library(ncdf4)
library(fields)
library(abind)
library(RColorBrewer)
library(rgdal)

# global, regular 1x1 grid
lons    = seq(-180,179,1)
nlon    = length(lons)
lats    = seq(-90,90,1) 
nlat    = length(lats)
alons   = array(lons,c(nlon,nlat))
alats   = array(rep(lats,each=nlon),c(nlon,nlat))
mask    = array(0, c(nlon,nlat))

# create masks files; with +-ss grid cells around city
for (ss in c(1)){

    # Cities
    # 1001 - Denver
    ix  = which(lons==-105)
    iy  = which(lats==40)
    mask[(ix-ss):(ix+ss),(iy-ss):(iy+ss)] = 1001
    
    # 3001 - Bejing
    ix  = which(lons==116)
    iy  = which(lats==40)
    mask[(ix-ss):(ix+ss),(iy-ss):(iy+ss)] = 3001
    
    # 5002 - Windhoek
    ix  = which(lons==17)
    iy  = which(lats==-23)
    mask[(ix-ss):(ix+ss),(iy-ss):(iy+ss)] = 5002
    
    ## WRITE NCDF
    # create and write the netCDF file -- ncdf4 version
    # define dimensions
    londim <- ncdim_def("lon","degrees_east",as.double(lons)) 
    latdim <- ncdim_def("lat","degrees_north",as.double(lats))
    # define variable
    mask_def <- ncvar_def("mask","-",list(londim,latdim),1e32,"mask",prec="single")
    
    # create netCDF file and put arrays
    boxs=2*ss+1
    ncout <- nc_create(paste("./data/masks/mask_cities",boxs,"x",boxs,".nc",sep=""),list(mask_def),force_v4=TRUE)
    
    # put variables
    ncvar_put(ncout,mask_def,mask)
    
    # put additional attributes into dimension and data variables
    ncatt_put(ncout,"lon","axis","X") #,verbose=FALSE) #,definemode=FALSE)
    ncatt_put(ncout,"lat","axis","Y")
    
    # add global attributes
    ncatt_put(ncout,0,"title","City-based mask")
    ncatt_put(ncout,0,"institution","Hydro-Climate Extremes Lab, Ghent University")
    ncatt_put(ncout,0,"source","")
    ncatt_put(ncout,0,"references","")
    history <- paste("Jessica Keune (jessica.keune@ugent.be)", date(), sep=", ")
    ncatt_put(ncout,0,"history",history)
    ncatt_put(ncout,0,"Conventions","CF1.6")
    
    # Get a summary of the created file:
    ncout
    
    nc_close(ncout)

} # ss

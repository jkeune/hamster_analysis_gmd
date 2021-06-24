# module load R/3.4.4-intel-2018a-X11-20180131

rm(list=ls())
Sys.setenv(TZ='GMT')
library(ncdf4)
library(fields)
library(abind)
library(RColorBrewer)
library(rgdal)
library(rworldmap)
library(sp)

##----------------------------------------------------------------
# User settings
##----------------------------------------------------------------
# dates etc.
syyyy	= 1980
eyyyy	= 2016
expids  = c("RH-10-20","SOD08-SCH19","SCH20","ALLPBL")
cexpids = c("RH-10","SCH19","SCH20","ALL-ABL")
exps    = c("linear")
cities  = c(1001,3001,5002)
rr      = 1.5 # grid box around city: +-1 (+0.5 for the grid cell)

## paths
opath 	= "figures"
ipath 	= "data/postpro/" 
spath 	= "data/staticdata/" 

# colors and breaks
ccol    = "black"
mybrs   = c(seq(0,0.9,0.1),seq(1,9,1),seq(10,30,10))
mycols  = colorRampPalette(brewer.pal("PuBuGn",n=9))(length(mybrs)-1)
mybrs2  = c(seq(0,9.5,0.5),seq(10,25,1))
mycols2 = colorRampPalette(brewer.pal("OrRd",n=9))(length(mybrs2)-1)

# additional functions
source("functions/mask2dfield.r")
source("functions/rotate.r")
source("functions/matrix2dany.r")
source("functions/coords2continent.r")
source("functions/mapplot.r")
source("functions/plotcity.r")
source("functions/plotlegend.r")
source("citysettings.r")

##----------------------------------------------------------------
## --- MAIN PROGRAM --- ##
##----------------------------------------------------------------

## -- (1) -- READ STATIC DATA
# -- grid
lon		  = seq(-180,179,1)
lat		  = seq(-90,90,1)
nlon		= length(lon)
nlat		= length(lat)
alon		= array(rep(lon, nlat),c(nlon,nlat)) 
alat		= array(rep(lat,each=nlon),c(nlon,nlat)) 
# -- ERA-Interim land mask
ifile = paste(spath,"/eafc_1x1.nc",sep="")
ncfile= nc_open(ifile)
olandmask = rotate(t(ncvar_get(ncfile,"var172")))
landmask	= array(NA, dim(olandmask))
landmask[1:180,]	  = olandmask[181:360,]
landmask[181:360,]	= olandmask[1:180,]
# -- continent mask: 0: ocean, 2: Africa, 3: Antarctica, 4: Australia, 5: Europe, 6: North America, 7: South America, 8: Asia 
points    = data.frame(lon=c(alon),lat=c(alat))
cmask     = array(coords2continent(points),c(nlon,nlat))
cname     = c(NA,"Africa","Antarctica","Australia","Europe","North America","South America","Asia")
cvalue    = seq(1,8,1)
# coastlines
coastlines= readOGR(path.expand(paste(spath,"/coastlines/",sep="")),layer="ne_10m_coastline")

# areas
areafile  = paste(spath,"/areas_1x1.nc",sep="")
areas2d   = ncvar_get(nc_open(areafile),"area")

# city mask
citymaskf = paste("data/masks/mask_cities3x3.nc",sep="")
citymask  = ncvar_get(nc_open(citymaskf),"mask")  

##----------------------------------------------------------------
## -- (2) -- READ ATTRIBUTION DATA    
##----------------------------------------------------------------

attdata          = list()
contributionmask = list()
sourcemask       = list()

# loop over all cities
for (icity in as.character(cities)){
  
  # read data for each city: varying experiments (exps) and setups (expids), all variables
  for (iexp in exps){
  for (iexpid in expids){
    iipath=sprintf("%s/%s/%s",ipath,icity,iexp)
    ifile=sprintf("%s/%s_biascor-attr_%s_%s_%s-%s_mean.nc",iipath,icity,iexpid,iexp,syyyy,eyyyy)
    idata     = list()
    for (ivar in c("Had","Had_Hs")){
      idata[[ivar]]   = ncvar_get(nc_open(ifile),ivar)
    }
  attdata[[icity]][[iexpid]][[iexp]]  = idata  
  }
  }
  
  ## source region masks per city (set grid cells which are never a source region to NA)
  # - contribution mask (x/48 experiments indicate a source region) 
  # - source mask (any: yes/no)
  ialldata                   = unlist(unlist(attdata[[icity]],recursive = FALSE),recursive = FALSE)
  contributionmask[[icity]]  = array(rowSums(sapply(ialldata,FUN=matrixany)),dim(alon))
  sourcemask[[icity]]        = (contributionmask[[icity]]>=1)+0
  # set never-source-regions to NA
  for (iexp in exps){
  for (iexpid in expids){
    attdata[[icity]][[iexpid]][[iexp]] = lapply(attdata[[icity]][[iexpid]][[iexp]], 
                                                FUN=mask2dfield,
                                                mask=sourcemask[[icity]],keep=1)
  }
  }  
}  

# get totals for text...
had = list()
for (icity in as.character(cities)){
  # city settings
  carea   = sum(mask2dfield(areas2d,mask=citymask,keep=as.numeric(icity)),na.rm=T)
  # get heat advection values 
  iexp="linear"
  ivars=c("Had","Had_Hs")
  for (ivar in ivars){
    for (iexpid in expids){
      itoplot = sum(attdata[[icity]][[iexpid]][[iexp]][[ivar]]*areas2d, na.rm=T)
      ivalue  = itoplot / carea
      had[[icity]][[iexpid]][[iexp]][[ivar]] = ivalue
    }
  }
}  
  
##----------------------------------------------------------------
## -- (3) -- PLOT
##----------------------------------------------------------------

for (icity in as.character(cities)){
  
  # city settings
  cname   = gdata[[icity]]$cname
  clon    = gdata[[icity]]$clon
  clat    = gdata[[icity]]$clat
  xrange  = gdata[[icity]]$xrange
  yrange  = gdata[[icity]]$yrange
  carea   = sum(mask2dfield(areas2d,mask=citymask,keep=icity),na.rm=T)
  
  # breaks and colors
  ibreaks  = c(seq(0,0.9,0.1),seq(1,10,1),20,30)
  icols    = colorRampPalette(brewer.pal("YlOrBr",n=9))(length(ibreaks)-1)
  
  ## PLOT: one pdf for each exps (linear, linear_upscaled, ...)
  for (iexp in exps){
  
    ofile = paste(opath,"/Had_maps_bias-correction_",cname,"_",iexp,"_",syyyy,"-",eyyyy,"_mean.pdf",sep="")
    pdf(ofile, width=20, height=8.25, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=14)
    
    # 4x 3-panel plot incl. legend
    par(oma=c(0,3,3,0.5),mgp=c(1.75,0.5,0))
    layout(matrix(c(seq(1,8,1),rep(9,4)), ncol=4, byrow=T), width=c(0.25,0.25,0.25,0.25),height=c(0.45,0.45,0.1))
    par(mar=c(0.75,0.75,0.75,0.75))
  
    i=1
    ivars=c("Had","Had_Hs")
    for (ivar in ivars){
      for (iexpid in expids){
        itoplot = attdata[[icity]][[iexpid]][[iexp]][[ivar]]
        #
        print(iexpid)
        print(sum(itoplot*areas2d,na.rm=T)/sum(carea,na.rm=T))
      #
      mapplot(alon,alat,itoplot,
              mybreaks=ibreaks,
              mycol=icols,
              mxlim=xrange,mylim=yrange,
              plotcoast=TRUE,
              ret="plot",
              scoastlines=coastlines)
      plotcity(xc=clon,yc=clat,rr=rr,ccol=ccol)
      legend("topleft",paste(letters[i],".",sep=""),bty="n",text.font=2,cex=2.75)
      i=i+1
      }
    }
    # legend
    par(mgp=c(1.75,1.5,0))
    plotlegend(mybreaks=ibreaks,
               ltext="",ltext2=expression('H [W m'^-2*']'),
               mycols=icols,isel=c(1,11,20,21,22,23),
               horizontal=TRUE,
               daxis=-3.0)
    # margin texts
    for (i in 1:length(ivars)){
      nvars=c("raw","source-corrected")
      mtext(side=2,outer=TRUE,rev(nvars)[i],at=seq(0.335,0.79,length.out=length(ivars))[i],cex=1.5,font=1)}
    for (i in 1:length(expids)){
      mtext(side=3,outer=TRUE,cexpids[i],at=c(0.125,0.375,0.625,0.875)[i],cex=1.5,font=1)}
    dev.off()
    print(sprintf("Successfully created: %s",ofile))

  }
  
}  

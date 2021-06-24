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
expids  = c("RH-10-20","SOD08-SCH19","ALLPBL","FAS19")
cexpids = c("RH-20","SOD08","ALL-ABL","FAS19")
exps    = c("linear","linear_upscaled","random","random_upscaled")
cities  = c(1001,3001,5002)
rr      = 1.5 # grid box around city: +-1 (+0.5 for the grid cell)

## paths
opath  	= "./figures"
ipath 	= "./data/hamster/postpro/" 
spath 	= "./data/hamster/staticdata/" 

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
    for (ivar in c("E2P","E2P_Es","E2P_Ps","E2P_EPs")){
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
  
  # breaks and colors...
  ibreaks  = c(seq(0,0.9,0.1),seq(1,10,1),20,30)
  icols    = colorRampPalette(brewer.pal("PuBu",n=9))(length(ibreaks)-1)
  
  
  ## PLOT: one pdf for each exps (linear, linear_upscaled, ...)
  for (iexp in exps){
  
    ofile = paste(opath,"/E2P_maps_bias-correction_",cname,"_",iexp,"_",syyyy,"-",eyyyy,"_mean.pdf",sep="")
    pdf(ofile, width=20.0, height=12.4, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=14)   # 3 rows
    
    # 4x 3-panel plot incl. legend
    par(oma=c(0,3,3,0.5),mgp=c(1.75,0.5,0))
    layout(matrix(c(seq(1,12,1),rep(13,4)), ncol=4, byrow=T), width=rep(0.25,4),height=c(0.2775,0.2775,0.2775,0.045))        # 4 rows
    par(mar=c(0.75,0.75,0.75,0.75))
  
    i=1
    #ivars=c("E2P","E2P_Es","E2P_Ps","E2P_EPs") # 4 rows
    ivars=c("E2P","E2P_Ps","E2P_EPs")           # 3 rows
    for (ivar in ivars){
      for (iexpid in expids){
      itoplot = 365*attdata[[icity]][[iexpid]][[iexp]][[ivar]]
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
               ltext=expression('E [mm y'^-1*']'),ltext2="",
               mycols=icols,isel=c(1,11,20,21,22,23),
               horizontal=TRUE,
               daxis=-2.4)
    # margin texts
    for (i in 1:length(ivars)){
      nvars=c("raw","sink-corrected","source-and-sink-corrected")
      mtext(side=2,outer=TRUE,rev(nvars)[i],at=seq(0.21,0.85,length.out=length(ivars))[i],cex=1.5,font=1)}
    for (i in 1:length(expids)){
      mtext(side=3,outer=TRUE,cexpids[i],at=c(0.125,0.375,0.625,0.875)[i],cex=1.75,font=1)}
    dev.off()
    print(sprintf("Successfully created: %s",ofile))

  }
  
}  

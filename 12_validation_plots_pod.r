# module load R/3.4.4-intel-2018a-X11-20180131
# script to plot all maps for all variables (P, E, H) and validation stats (BIAS; POD, POFD, PSS) in one PDF

Sys.setenv(TZ='GMT')
library(ncdf4)
library(fields)
library(abind)
library(RColorBrewer)
library(rgdal)
library(rworldmap)
library(sp)

# User settings
syyyy	= 1980
eyyyy	= 2016
expids	= c("RH-10-20","SOD08-SCH19","ALLPBL","FAS19","SCH20")
cexpids = c("RH-20","SOD08","ALL-ABL","FAS19")
cexpidsh= c("RH-10","SCH19","ALL-ABL","SCH20")
imean 	= "mean"
hthres	= 1
mthres	= 0.1

# Settings
opath 	= "figures"
ipath 	= "data/postpro/" 
spath 	= "data/staticdata/" 

# Functions
source("functions/rotate.r")
source("functions/mask2dfield.r")
source("functions/coords2continent.r")
source("functions/readnc_validationmean.r")
source("functions/mapplot.r")
source("functions/plotlegend.r")
source("functions/boxplot_adv.r")


## ----- MAIN ------

## STATIC DATA
# -- grid
lon		  = seq(-180,179,1)
lat		  = seq(-90,90,1)
nlon		= length(lon)
nlat		= length(lat)
alon		= array(rep(lon, nlat),c(nlon,nlat)) 
alat		= array(rep(lat,each=nlon),c(nlon,nlat)) 
# -- ERA-Interim land mask
ifile = paste(spath,"eafc_1x1.nc",sep="")
ncfile= nc_open(ifile)
olandmask = rotate(t(ncvar_get(ncfile,"var172")))
landmask	= array(NA, dim(olandmask))
landmask[1:180,]	  = olandmask[181:360,]
landmask[181:360,]	= olandmask[1:180,]
# -- continent mask: 0: ocean, 2: Africa, 3: Antarctica, 4: Australia, 5: Europe, 6: North America, 7: South America, 8: Asia 
points    = data.frame(lon=c(alon),lat=c(alat))
cmask     = array(coords2continent(points),c(nlon,nlat))
cname     = c("land","Africa","Antarctica","Australia","Europe","North America","South America","Asia","ocean","all")
cvalue    = seq(1,10,1)
# coastlines
coastlines= readOGR(path.expand(paste(spath,"/coastlines/",sep="")),layer="ne_10m_coastline")


## VALIDATION DATA (diagnosis, global)
valdata = list(P=NULL, E=NULL, H=NULL)
for (ivar in c("P","E","H")){
  for (expid in expids){
    if (ivar=="H"){ithresh=hthres}else{ithresh=mthres}
    if (ivar=="P" & expid!="ALLPBL"){next}
    if (ivar!="H" & expid=="SCH20"){next}
    if (ivar=="H" & expid=="FAS19"){next}
    ifile = paste(ipath,"/validation/global/",ivar,"_",expid,"_daily_",syyyy,"-",eyyyy,"_all_thresh-",ithresh,".nc", sep="")
    valdata[[ivar]][[expid]] = readnc_validationmean(ifile, ret="data")
  }
}
## continent data
cvaldata = list()
for (ivar in c("P","E","H")){
  for (expid in expids){
    if (ivar=="P" & expid!="ALLPBL"){next}
    if (ivar!="H" & expid=="SCH20"){next}
    if (ivar=="H" & expid=="FAS19"){next}
    # all land (ic=1)
    ic = 1
    cvaldata[[ivar]][[expid]][[cname[ic]]]= lapply(valdata[[ivar]][[expid]],FUN=mask2dfield,keep=1,mask=landmask)
    # continents (ic=2:8)
    for (ic in 2:8){
      cvaldata[[ivar]][[expid]][[cname[ic]]]       = lapply(valdata[[ivar]][[expid]],FUN=mask2dfield,keep=ic,mask=cmask)
    }
    # ocean (ic=9)
    ic = 9
    cvaldata[[ivar]][[expid]][[cname[ic]]]= lapply(valdata[[ivar]][[expid]],FUN=mask2dfield,keep=0,mask=landmask)
    # all (ic=10)
    ic = 10 
    cvaldata[[ivar]][[expid]][[cname[ic]]]= valdata[[ivar]][[expid]]
  }
}


## -- (3) -- PLOT
# for testing: layout(matrix(c(3,4,1,2),ncol=2,byrow=TRUE),width=c(0.7,0.3),height=c(0.3,0.7))

## -- PLOT ALL DATA
ofile = paste(opath,"/Validation_P+E+H_bias-vs-pod_",syyyy,"-",eyyyy,"_",imean,"_all.pdf",sep="")
pdf(ofile, width=12.0, height=11, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=14)

# 2x2
layout(matrix(c(3,4,7,8,1,2,5,6,11,12,13,13,9,10,13,13),ncol=4,byrow=TRUE),width=c(0.875/2,0.125/2,0.875/2,0.125/2),height=c(rep(c(0.05,0.25),2)))
par(oma=c(0,0,0,0))#,#mgp=c(1.75,0.75,0))

## P
boxplot_adv(cvaldata,
            xrange=c(-4,3),
            yrange=c(0,100),
            mxlab=expression('s'['bias']*'(P) [mm d'^-1*']'),
            mylab=expression('s'['pod']*'(P) [%]'),
            varname="P",
            cname=cname,
            mycols=c(brewer.pal("Set1",n=3)[2]),
            expids=expids,
            lexpids=cexpids[c(2,1,3,4)],
            iexpids=c(1),
            mtitle="a.",
            plotleg1=FALSE,
            plotleg2=TRUE,
            plotpss=FALSE,
            plotpod=TRUE,
            labpos=-4.75,
            boxwex=0.325)

## E
boxplot_adv(cvaldata,
            xrange=c(-1.5,5),
            yrange=c(0,100),
            mxlab=expression('s'['bias']*'(E) [mm d'^-1*']'),
            mylab=expression('s'['pod']*'(E) [%]'),
            varname="E",
            cname=cname,
            mycols=c(brewer.pal("Set1",n=5)[c(1,2)],"grey70","grey40"),
            expids=expids,
            lexpids=cexpids,
            iexpids=c(1,2,3,4),
            mtitle="b.",
            plotleg1=FALSE,
            plotleg2=TRUE,
            plotpss=FALSE,
            plotpod=TRUE,
            labpos=-2.25,
            boxwex=0.175)
## H
hcols=c(brewer.pal("Set1",n=5)[c(1,4)],"grey70",NA,brewer.pal("Set1",n=5)[c(5)])
boxplot_adv(cvaldata,
            xrange=c(-10,150),
            yrange=c(0,100),
            mxlab=expression('s'['bias']*'(H) [W m'^-2*']'),
            mylab=expression('s'['pod']*'(H) [%]'),
            varname="H",
            cname=cname,
            mycols=hcols,#c(brewer.pal("Set1",n=5)[c(1,4)],brewer.pal("Set1",n=5)[c(5)],"grey70"),
            expids=expids,
            lexpids=cexpidsh,
            iexpids=c(1,2,4,3),
            mtitle="c.",
            plotleg1=FALSE,
            plotleg2=TRUE,
            plotpss=FALSE,
            plotpod=TRUE,
            labpos=-27.5,
            boxwex=0.175)
## legend 
par(mar=c(0,0,0.5,0))
par(mgp=c(1.75,0.5,0))
plot.new()
legend(0.32,0.8,cname[c(1,9)],pch=c(19,15),bty="l",cex=1.75,ncol=2)
legend("center",cname[c(2:8)],pch=c(NA,6,2,5,0,10,8,4,NA)[c(2:8)],bty="l",cex=1.75,ncol=2)

dev.off()
print(sprintf("Successully created: %s !",ofile))


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
expids 	= c("RH-10-20")
hthres	= 1
mthres	= 0.1

# paths
opath 	= "./figures"
ipath 	= "./data/hamster/postpro/" 
spath 	= "./data/hamster/staticdata/" 

# Functions
source("functions/rotate.r")
source("functions/mask2dfield.r")
source("functions/coords2continent.r")
source("functions/readnc_validationmean.r")
source("functions/mapplot.r")
source("functions/plotcity.r")
source("functions/plotallcities.r")
source("functions/plotlegend.r")
source("citysettings.r")

## ----- MAIN ------

## STATIC DATA
  # -- grid
  lon		  = seq(-180,179,1)
  lat		  = seq(-90,90,1)
  nlon		= length(lon)
  nlat		= length(lat)
  alon		= array(rep(lon, nlat),c(nlon,nlat)) 
  alat		= array(rep(lat,each=nlon),c(nlon,nlat)) 
  # coastlines
  coastlines= readOGR(path.expand(paste(spath,"/coastlines/",sep="")),layer="ne_10m_coastline")

for (expid in expids){
  
  ## VALIDATION DATA (diagnosis, global)
    ## -- list for P, E,H 
    valdata = list(P=NULL, E=NULL, H=NULL)
    for (ivar in c("P","E","H")){
      if (ivar=="H"){ithresh=hthres}else{ithresh=mthres}
      if (ivar=="P"){iexpid="ALLPBL"}else{iexpid=expid}
      ifile = paste(ipath,"/validation/global/",ivar,"_",iexpid,"_daily_",syyyy,"-",eyyyy,"_all_thresh-",ithresh,".nc", sep="")
      valdata[[ivar]] = readnc_validationmean(ifile, ret="data")
    }
  
  
  ## -- PLOT ALL DATA
  ofile = paste(opath,"/Validation_maps_",syyyy,"-",eyyyy,"_",expid,"_mean_all_",hthres,"-",mthres,".pdf",sep="")
  pdf(ofile, width=18.0, height=11.75, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=14)
  
  # 3-panel plot incl. legend
  layout(matrix(seq(1,20,1), ncol=5, byrow=T), width=c(0.30,0.30,0.05,0.30,0.05))
  par(oma=c(0,3,3,0.5),mgp=c(1.75,0.75,0))
  
    ## BIAS
      par(mar=c(0.75,0.75,0.75,0.75))
      mybrs   = c(seq(-15,-10,5),seq(-9,-1,1),-0.1,0,0.1,seq(1,9,1),seq(10,15,5))
      mycols  = colorRampPalette(brewer.pal("RdBu",n=9))(length(mybrs)-1)
      mapplot(alon,alat,valdata$P$bias,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      # adding city names
      for (icity in 1:length(gdata)){
        text(gdata[[icity]]$clon,gdata[[icity]]$clat-10,gdata[[icity]]$cname,cex=1.75)}
      legend("topleft","a.",bty="n",text.font=2,cex=2.75)
      mapplot(alon,alat,valdata$E$bias,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","b.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,ltext2="",ltext=expression('[mm d'^-1*']'),mycols=mycols,daxis=-4.25)
      par(mar=c(0.75,0.75,0.75,0.75))
      mybrs   = c(seq(-100,-10,10),0,seq(10,100,10))
      mycols  = colorRampPalette(brewer.pal("RdBu",n=9))(length(mybrs)-1)
      mapplot(alon,alat,valdata$H$bias,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","c.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,ltext2="",ltext=expression('[W m'^-2*']'),mycols=mycols,daxis=-4.25)
      
    ## POD
      par(mar=c(0.75,0.75,0.75,0.75))
      mybrs   = c(seq(0,100,5))
      mycols  = colorRampPalette(brewer.pal("RdBu",n=9)[6:9])(length(mybrs)-1)
      mapplot(alon,alat,100*valdata$P$pod,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","d.",bty="n",text.font=2,cex=2.75)
      mapplot(alon,alat,100*valdata$E$pod,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","e.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[%]",ltext2="",daxis=-4.25)
      par(mar=c(0.75,0.75,0.75,0.75))
      mapplot(alon,alat,100*valdata$H$pod,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","f.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[%]",ltext2="",daxis=-4.25)
      
    ## POFD
      par(mar=c(0.75,0.75,0.75,0.75))
      mybrs   = c(seq(0,100,5))
      mycols  = colorRampPalette(brewer.pal("RdBu",n=9)[4:1])(length(mybrs)-1)
      mapplot(alon,alat,100*valdata$P$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      legend("topleft","g.",bty="n",text.font=2,cex=2.75)
      mapplot(alon,alat,100*valdata$E$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","h.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[%]",ltext2="",daxis=-4.25)
      par(mar=c(0.75,0.75,0.75,0.75))
      mapplot(alon,alat,100*valdata$H$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","i.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[%]",ltext2="",daxis=-4.25)
    ## PSS
      par(mar=c(0.75,0.75,0.75,0.75))
      mybrs   = c(seq(-1,-0.1,0.1),0,seq(0.1,1,0.1))
      mycols  = colorRampPalette(brewer.pal("RdBu",n=9))(length(mybrs)-1)
      mapplot(alon,alat,valdata$P$pod-valdata$P$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","j.",bty="n",text.font=2,cex=2.75)
      mapplot(alon,alat,valdata$E$pod-valdata$E$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","k.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[-]",ltext2="",daxis=-4.25)
      par(mar=c(0.75,0.75,0.75,0.75))
      mapplot(alon,alat,valdata$H$pod-valdata$H$pofd,mybreaks=mybrs,plotcoast=TRUE,mycol=mycols)
      plotallcities(gdata)
      legend("topleft","l.",bty="n",text.font=2,cex=2.75)
      plotlegend(mybreaks=mybrs,mycols=mycols,ltext="[-]",ltext2="",daxis=-4.25)
  
      # margin texts
      for (i in 1:length(c("P","E","H"))){
        mtext(side=3,outer=TRUE,c("P","E","H")[i],at=c(0.15,0.475,0.825)[i],cex=1.75,font=1)}
      valmeasures=c(expression('s'['bias']),expression('s'['pod']),expression('s'['pofd']),expression('s'['PSS']))
      for (i in 1:length(valmeasures)){
        mtext(side=2,outer=TRUE,rev(valmeasures)[i],at=seq(0.125,0.875,length.out=length(valmeasures))[i],cex=1.75,font=1)}
      
  dev.off()
  print(sprintf("Successully created: %s !",ofile))

}

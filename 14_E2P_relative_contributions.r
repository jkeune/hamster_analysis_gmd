# module load R/3.4.4-intel-2018a-X11-20180131

rm(list=ls())
Sys.setenv(TZ='GMT')
library(ncdf4)
library(fields)
library(abind)
library(RColorBrewer)
library(rgdal)

##----------------------------------------------------------------
# User settings
##----------------------------------------------------------------
syyyy	= 1980
eyyyy	= 2016
expids  = c("RH-10-20","SOD08-SCH19","ALLPBL","FAS19")
cexpids = c("RH-20","SOD08","ALL-ABL","FAS19")
exps    = c("linear_upscaled","random2_upscaled")
cities  = c(1001,3001,5002)
imean   = "bwmean"

## paths
opath 	= "figures"
ipath 	= "data/postpro/" 
spath 	= "data/staticdata/" 
erafile = paste(spath,"/eafc_1x1.nc",sep="")
areafile= paste(spath,"/areas_1x1.nc",sep="")

# additional functions
source("functions/mask3dfield.r")
source("functions/rotate.r")
source("functions/matrixany.r")
source("citysettings.r")

##----------------------------------------------------------------
## --- MAIN PROGRAM --- 
##----------------------------------------------------------------

## -- (1) -- READ STATIC DATA    
areas2d = ncvar_get(nc_open(areafile),"area")
areas3d = NULL
for (id in 1:16){areas3d=abind(areas3d,areas2d,along=3)}

  
##----------------------------------------------------------------
## -- (2) -- READ ATTRIBUTION DATA    
##----------------------------------------------------------------
  
attdata          = list()
# loop over all cities
for (icity in as.character(cities)){
  
  # read data for each city: varying experiments (exps) and setups (expids), all variables
  for (iexp in exps){
    for (iexpid in expids){
      iipath=sprintf("%s/%s/%s",ipath,icity,iexp)
      ifile=sprintf("%s/%s_biascor-attr_%s_%s_%s-%s_%s.nc",iipath,icity,iexpid,iexp,syyyy,eyyyy,imean)
      idata     = list()
      for (ivar in c("E2P","E2P_Ps","E2P_EPs")){
        # multiply with areas already ( to be able to sum contribution up... )
        idata[[ivar]]   = ncvar_get(nc_open(ifile),ivar)*areas3d
      }
      attdata[[icity]][[iexpid]][[iexp]]  = idata  
    }
  }

}

##----------------------------------------------------------------
## -- PLOT DATA
##----------------------------------------------------------------
  
plotinit=function(){
  plot(NA,NA,t="n",lwd=2.5,xlim=c(0,15),ylim=c(0,33),xaxt="n",yaxt="n",xlab="backward days",ylab="relative contribution [%]",yaxs="i")
  axis(1,at=seq(0,15,1),labels=TRUE,tcl=-0.75)
  axis(2,at=pretty(c(0,100),n=10),labels=TRUE,tcl=-0.75)
  axis(2,at=pretty(c(0,100),n=20),labels=FALSE,tcl=-0.75)
  axis(2,at=pretty(c(0,100),n=100),labels=FALSE,tcl=-0.35)
  axis(4,at=seq(0,33,length.out=11),labels=seq(0,100,10),tcl=-0.75)
  axis(4,at=seq(0,33,length.out=21),labels=FALSE,tcl=-0.35)
  mtext("cumulative contributions [%]",side=4,line=+2,cex=0.7)
}  
  

ofile = paste(opath,"/Relative_contributions_E2P_RH-20_",syyyy,"-",eyyyy,"_",imean,".pdf",sep="")
pdf(ofile, width=6, height=12, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=16)

par(oma=c(0,0,0,0.5),mgp=c(1.75,0.75,0))
par(mar=c(3.0,3.0,0.75,3.5))
par(mfrow=c(3,1))

# settings
mylwd=4.75
mylwd2=1.5

# plot (a): criteria
expidcol=c(brewer.pal("Set1",n=3)[c(1,2)],"grey70","grey40")
idiff=seq(-0.325,+0.325,length.out=4)
ivar="E2P_EPs"
iexp="linear_upscaled"
plotinit()
i=1
for (iexpid in expids){
  # sum over all cities to get city-independent relative contributions
  itotal = 0
  icontr = rep(0,16)
  for (icity in c("1001","3001","5002")){
    itotal    = itotal + sum(attdata[[icity]][[iexpid]][[iexp]][[ivar]],na.rm=T)
    icontr    = icontr + apply(attdata[[icity]][[iexpid]][[iexp]][[ivar]],c(3),FUN=sum,na.rm=T)
  }
  rcontr    = icontr / itotal
  lines(seq(0,15,1)+idiff[i],rev(rcontr)*100,t="h",lwd=mylwd,lend=1,col=expidcol[i],lend=1)
  lines(seq(0,15,1),33*cumsum(rev(rcontr)),t="l",lwd=mylwd2,col=expidcol[i]) # normalized by ylim
  i=i+1
}
legend("topright",c("",cexpids),col=c(NA,expidcol),pch=15,bty="n")
legend("topleft","a.",text.font=2,bty="n",cex=1.35)

# plot (b): bias-correction
bccol=c(brewer.pal("Set1",n=3)[1],brewer.pal("Set1",n=8)[7])
idiff=c(-0.15,+0.15)
iexpid="RH-10-20"
iexp="linear_upscaled"
plotinit()
i=1
for (ivar in c("E2P_EPs","E2P_Ps")){
  # sum over all cities to get city-independent relative contributions
  itotal = 0
  icontr = rep(0,16)
  for (icity in c("1001","3001","5002")){
    rtotal    = itotal + sum(attdata[[icity]][[iexpid]][[iexp]][["E2P_EPs"]],na.rm=T)
    itotal    = itotal + sum(attdata[[icity]][[iexpid]][[iexp]][[ivar]],na.rm=T)
    icontr    = icontr + apply(attdata[[icity]][[iexpid]][[iexp]][[ivar]],c(3),FUN=sum,na.rm=T)
  }
  if (ivar=="E2P"){
  rcontr    = icontr / rtotal
  }else{
  rcontr    = icontr / itotal
  }
  lines(seq(0,15,1)+idiff[i],rev(rcontr)*100,t="h",lwd=mylwd,lend=1,col=bccol[i],lend=1)
  lines(seq(0,15,1),33*cumsum(rev(rcontr)),t="l",lwd=mylwd2,col=bccol[i])
  i=i+1
}
legend("topright",c("","source-sink-corrected","sink-corrected"),col=c(NA,bccol),pch=15,bty="n")
legend("topleft","b.",text.font=2,bty="n",cex=1.35)


# plot (c): attribution methods
expcol=c(brewer.pal("Set1",n=3)[1],"black")#brewer.pal("PuOr",n=6)[6])
idiff=c(-0.15,+0.15)
iexpid="RH-10-20"
ivar="E2P_EPs"
plotinit()
i=1
for (iexp in c("linear_upscaled","random2_upscaled")){
  # sum over all cities to get city-independent relative contributions
  itotal = 0
  icontr = rep(0,16)
  for (icity in c("1001","3001","5002")){
    itotal    = itotal + sum(attdata[[icity]][[iexpid]][[iexp]][[ivar]],na.rm=T)
    icontr    = icontr + apply(attdata[[icity]][[iexpid]][[iexp]][[ivar]],c(3),FUN=sum,na.rm=T)
  }
  rcontr    = icontr / itotal
  lines(seq(0,15,1)+idiff[i],rev(rcontr)*100,t="h",lwd=mylwd,lend=1,col=expcol[i],lend=1)
  lines(seq(0,15,1),33*cumsum(rev(rcontr)),t="l",lwd=mylwd2,col=expcol[i])
  i=i+1
}
legend("topright",c("","linear","random"),col=c(NA,expcol),pch=15,bty="n")
legend("topleft","c.",text.font=2,bty="n",cex=1.35)

dev.off()

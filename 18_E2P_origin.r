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
expids	= c("RH-10-20","SOD08-SCH19","ALLPBL","FAS19")
cexpids = c("RH-20","SOD08","ALL-ABL","FAS19")
exps    = c("linear","random")
cities  = c(1001,3001,5002)
vars    = c("E2P_EPs","E2P_Ps")
rr      = 1.5 # grid box around city: +-1 (+0.5 for the grid cell)

## paths
opath  	= "figures"
ipath 	= "data/postpro/" 
spath 	= "data/staticdata/" 
mpath 	= "data/masks"

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

# -- areas
areafile= paste(spath,"/areas_1x1.nc",sep="")
areas2d = ncvar_get(nc_open(areafile),"area")
areas3d = areas2d
for (id in 1:15){areas3d=abind(areas3d,areas2d,along=3)}

# -- city mask
cityfile= paste(mpath,"/mask_cities3x3.nc",sep="")
citymask= ncvar_get(nc_open(cityfile),"mask")

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
cnames    = c("land","Africa","Antarctica","Australia","Europe","North America","South America","Asia","ocean","all")
cvalue    = seq(1,10,1)
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
    for (ivar in vars){
      # multiply with areas here... 
      idata[[ivar]]   = ncvar_get(nc_open(ifile),ivar)*areas2d
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

convertlist2str=function(mystring){
  # expid
  if (grepl("RH-10-20",mystring)){
    if (grepl("linear",mystring)){
      out = expression("RH-10; linear")
    }else if (grepl("random",mystring)){
      out = expression("RH-10; random")
    }
  }else if (grepl("FAS19",mystring)){
    if (grepl("linear",mystring)){
      out = expression("FAS19; linear")
    }else if (grepl("random",mystring)){
      out = expression("FAS19; random")
    }
  }else if (grepl("SOD08-SCH19",mystring)){
    if (grepl("linear",mystring)){
      out = expression("SOD08; linear")
    }else if (grepl("random",mystring)){
      out = expression("SOD08; random")
    }
  }else if (grepl("ALL",mystring)){
    if (grepl("linear",mystring)){
      out = expression("ALL-ABL; linear")
    }else if (grepl("random",mystring)){
      out = expression("ALL-ABL; random")
    }
}
return(out)}


# 3 stacks: city, land (incl. city), ocean
cols1 = brewer.pal("Dark2",n=3)[c(2,1,3)]
odata = list()

for (icity in as.character(cities)){
  for (iexpid in expids){
    for (iexp in exps){ 
      for (ivar in "E2P_EPs"){ # only E2P_EPs for plotting...
        idata= attdata[[icity]][[iexpid]][[iexp]][[ivar]]
        isum = sum(idata,na.rm=T)
        odata[[icity]][[iexpid]][[iexp]][[ivar]] = rep(NA,3)
        # city
        odata[[icity]][[iexpid]][[iexp]][[ivar]][1] = sum(mask2dfield(idata,citymask,keep=as.numeric(icity)),na.rm=T)/isum
        # land (minus city)
        odata[[icity]][[iexpid]][[iexp]][[ivar]][2] = sum(mask2dfield(idata,(cmask>0)+0,keep=1),na.rm=T)/isum - odata[[icity]][[iexpid]][[iexp]][[ivar]][1]
        # ocean
        odata[[icity]][[iexpid]][[iexp]][[ivar]][3] = sum(mask2dfield(idata,(cmask>0)+0,keep=0),na.rm=T)/isum
      }
    }
  }
}
  
  
ofile = paste(opath,"/E2P_origins_all-cities_",syyyy,"-",eyyyy,"_mean.pdf",sep="")
pdf(ofile, width=10.66, height=4.5, onefile = TRUE, family = "sans", fonts = NULL, version = "1.2", pointsize=16)
# 1x 3-panel plot incl. legend
layout(matrix(1:4,ncol=4),width=c(rep(0.3,3),0.1))
#par(mfrow=c(1,3))
par(mgp=c(1.75,0.5,0))
par(mar=c(6,3.5,2.5,0))
par(oma=c(0,0,0,0))

for (j in 1:3){ # loop over cities
  # axis text rotation: https://stackoverflow.com/questions/10286473/rotating-x-axis-labels-in-r-for-barplot/21978596
  # https://www.r-graph-gallery.com/211-basic-grouped-or-stacked-barplot.html
  par(mgp=c(1.75,0.75,0))
  
  mydata = unlist(unlist(odata[[j]],recursive=FALSE),recursive=FALSE)
  toplot = NULL
  for (i in 1:length(mydata)){
    toplot = cbind(toplot,mydata[[i]])
  }
  # sort by city contribution...
  myorder = rev(order(toplot[1,]))
  barplot(100*toplot[,myorder],xlab="",ylab="origin [%]",col=cols1, yaxs="i",
          border=NA,offset=0,las=2,yaxt="n",space=0.5,ylim=c(0,110),
          #legend.text=c("city","land","ocean"),
          #names.arg=mapply(unlist(names(mydata)),FUN=convertlist2str)[myorder],
          cex.names=0.85)
  text(seq(1, 11.5, length.out=ncol(toplot)), par("usr")[3]-1.15, 
       srt = 60, adj = 1, xpd = TRUE,
       labels = unlist(lapply((names(mydata)),FUN=convertlist2str),recursive=FALSE,use.names=FALSE)[myorder], cex = 0.95)
  axis(2,at=seq(0,100,20),tcl=-0.75,labels=TRUE)
  axis(2,at=seq(0,100,10),tcl=-0.75,labels=FALSE)
  axis(2,at=seq(0,100,5),tcl=-0.35,labels=FALSE)
  #box("plot")
  mtext(at=c(-0.75,150),font=2,bty="n",text=paste(letters[j],".",sep=""),outer=FALSE)
  mtext(at=c(0.75,150),font=1,bty="n",text=paste(gdata[[j]]$cname),outer=FALSE,adj=0)
  #legend("topleft",text.font=2,bty="n",paste(letters[j],".",sep=""),cex=1.5)
}
# legend
  par(mar=c(0,0.5,0,0))
  plot.new()
  legend("center",bty="l",pch=rep(15,3),col=cols1,c("city","land","ocean"))
dev.off()
print(sprintf("Successfully created: %s",ofile))

 

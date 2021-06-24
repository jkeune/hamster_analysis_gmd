# https://stackoverflow.com/questions/21708488/get-country-and-continent-from-longitude-and-latitude-point-in-r/21727515
#library(sp)
#library(rworldmap)
coords2continent = function(points){
# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees

   countriesSP <- getMap(resolution='low')

  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  

    # use 'over' to get indices of the Polygons object containing each point 
    indices = over(pointsSP, countriesSP)

    cont=indices$REGION # returns the continent (7 continent model)

    ccont=as.character(cont)
    ncont=rep(NA,length(ccont))
    ncont[which(ccont=="Africa")]=2
    ncont[which(ccont=="Antarctica")]=3
    ncont[which(ccont=="Australia")]=4
    ncont[which(ccont=="Europe")]=5
    ncont[which(ccont=="North America")]=6
    ncont[which(ccont=="South America")]=7
    ncont[which(ccont=="Asia")]=8
    ncont[which(is.na(ccont))]=0

return(ncont)}


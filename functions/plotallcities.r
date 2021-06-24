plotallcities=function(gdata){
  for (ic in 1:length(gdata)){
  plotcity(xc=gdata[[ic]]$clon,yc=gdata[[ic]]$clat,rr=1.5,ccol="black")
  }  
}


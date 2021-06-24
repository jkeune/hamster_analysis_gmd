mask3dfield=function(mydata,mask,keep=1){
for (i in 1:(dim(mydata)[3])){
    mydata[,,i][which(mask!=keep)]   = NA
}
return(mydata)
}

mask2dfield=function(mydata,mask,keep=1){
    mydata[which(mask!=keep)]   = NA
return(mydata)
}

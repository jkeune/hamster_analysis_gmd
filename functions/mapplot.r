mapplot = function(alon,alat,myadata,
                   mybreaks,
                   mycol=colorRampPalette(brewer.pal("RdBu",n=9))(length(mybreaks)-1),
                   plotcoast=FALSE,
                   ret="plot",
                   revcol=FALSE,
                   mxlim=c(-180,180),mylim=c(-90,90),
                   scoastlines=coastlines){
    myzlim  = c(min(mybreaks),max(mybreaks))
    if (isTRUE(revcol)){mycol=rev(mycol)}
    if(ret=="plot"){
    myadata[which(myadata=="Inf")]=NA
    myadata[which(myadata=="-Inf")]=NA
    myadata[which(myadata>=myzlim[2])]=myzlim[2]-0.001
    myadata[which(myadata<=myzlim[1])]=myzlim[1]+0.001
    poly.image(alon,alat,myadata,col=mycol,breaks=mybreaks,
               xaxs="i",yaxs="i",xlab="",ylab="",xaxt="n",yaxt="n",xlim=mxlim,ylim=mylim, asp=1)
    if(plotcoast==TRUE){lines(scoastlines,col="grey50")}
    box("plot")
    }
    if(ret=="col"){return(mycol)}
}

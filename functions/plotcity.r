plotcity = function(xc=116,yc=40,rr=1.5,ccol="red",...){
    points(xc,yc,pch=19,col=ccol,cex=0.75)
    segments(xc-rr,yc-rr,xc+rr,yc-rr,col=ccol,lwd=1.5)
    segments(xc-rr,yc-rr,xc-rr,yc+rr,col=ccol,lwd=1.5)
    segments(xc+rr,yc+rr,xc-rr,yc+rr,col=ccol,lwd=1.5)
    segments(xc+rr,yc+rr,xc+rr,yc-rr,col=ccol,lwd=1.5)
}

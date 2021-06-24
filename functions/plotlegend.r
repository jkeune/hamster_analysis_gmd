plotlegend = function(mybreaks,
                      mycols=colorRampPalette(brewer.pal("RdBu",n=9))(length(mybreaks)-1),
                      revcol=FALSE,
                      ltext,ltext2,
                      isel=NULL,
                      daxis=-3.75,horizontal=FALSE){
    par(mar=c(0,0,0,0))
    plot.new()
    plot.window(xlim=0:1,ylim=0:1)
    pcols = mapplot(mybreaks=mybreaks,ret="col",mycol=mycols)
    if (isTRUE(revcol)){pcols=rev(pcols)}
    
    if (isFALSE(horizontal)){
        rect(0, seq(0.05,0.8,length=length(mybreaks))[-length(mybreaks)], 0.25, seq(0.05,0.8,length=length(mybreaks))[-1], col=pcols)
        axis(4, at=seq(0.05,0.8,length=length(mybreaks)),labels=FALSE,tcl=-0.35,las=2,line=daxis)
        if (is.null(isel)){
        axis(4, at=seq(0.05,0.8,length=length(mybreaks))[seq(1,length(mybreaks),2)],labels=mybreaks[seq(1,length(mybreaks),2)],tcl=-0.65,las=2,line=daxis,cex.axis=1.5)}
        else{
        axis(4, at=seq(0.05,0.8,length=length(mybreaks))[isel],labels=mybreaks[isel],tcl=-0.65,las=2,line=daxis,cex.axis=1.5)
        }
        mtext(ltext, side=3,line=-2.75,cex=1.35)
        mtext(ltext2, side=3,line=-4.5,cex=1.15)
    }    
    if (isTRUE(horizontal)){
        rect(seq(0.15,0.75,length=length(mybreaks))[-length(mybreaks)], 0.6, seq(0.15,0.75,length=length(mybreaks))[-1], 0.9, col=pcols)
        axis(1, at=seq(0.15,0.75,length=length(mybreaks)),labels=FALSE,tcl=-0.35,las=1,line=daxis, cex=1.15)
        if (is.null(isel)){
            axis(1, at=seq(0.15,0.75,length=length(mybreaks))[seq(1,length(mybreaks),2)],labels=mybreaks[seq(1,length(mybreaks),2)],tcl=-0.75,las=1,line=daxis,cex.axis=2.25)}
        else{
            axis(1, at=seq(0.15,0.75,length=length(mybreaks))[isel],labels=mybreaks[isel],tcl=-0.75,las=1,line=daxis,cex.axis=2.25)
        }
        mtext(ltext, side=4,line=-23.75,cex=1.75, las=1)
        mtext(ltext2, side=4,line=-14.5,cex=1.85, las=1)
    }
}


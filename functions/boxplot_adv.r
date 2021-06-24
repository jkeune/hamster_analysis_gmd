boxplot_adv=function(cvaldata,
                     xrange=c(-5,5),
                     yrange=c(-1,1),
                     mxlab=expression('s'['bias']*'(E) [mm d'^-1*']'),
                     mylab=expression('s'['PSS']*'(E) [-]'),
                     varname="E",
                     cname=cname,
                     mycols=c(brewer.pal("Set1",n=3)[1],"grey50","grey80"),
                     expids=expids,
                     lexpids=cexpids,
                     iexpids=seq(1,length(expids),1),
                     mtitle="",plotleg1=TRUE,plotleg2=TRUE,
                     plotpss=TRUE,plotpod=FALSE,labpos=-5,boxwex=0.175){
  # scatterplot
  par(mar=c(3.95,4.65,0.15,0.15),mgp=c(2.65,0.95,0))
  plot(1,1,t="n",xlab=mxlab,ylab=mylab,xlim=xrange,ylim=yrange,xaxt="n",yaxt="n",cex=1.5,cex.lab=1.85)
  abline(h=0,lty=3,col="grey60")
  abline(v=0,lty=3,col="grey60")
  for (i in iexpids){
    for(ic in 1:9){
      xmet    = mean(cvaldata[[varname]][[i]][[ic]][['bias']],na.rm=T)
      if(plotpss){
        ymet    = mean(cvaldata[[varname]][[i]][[ic]][['pod']]-cvaldata[[varname]][[i]][[ic]][['pofd']],na.rm=T)
      }
      if(plotpod){
        ymet    = mean(100*cvaldata[[varname]][[i]][[ic]][['pod']],na.rm=T)
      }
      points(xmet,ymet,pch=c(19,6,2,5,0,10,8,4,15)[ic],col=adjustcolor(mycols[i],1),cex=1.95)
    }
  }
  if(plotleg1==TRUE){legend("bottomleft",cname[1:9],pch=c(19,6,2,5,0,10,8,4,15),bty="n",cex=1.75)}
  axis(1,at=pretty(xrange,n=8),labels=TRUE,tcl=-0.75,cex.axis=1.5)
  axis(1,at=pretty(xrange,n=50),labels=FALSE,tcl=-0.35)
  axis(2,at=pretty(yrange,n=8),labels=TRUE,tcl=-0.75,cex.axis=1.5)
  axis(2,at=pretty(yrange,n=50),labels=FALSE,tcl=-0.35)
  if(plotleg2==TRUE){legend("bottomright",lexpids[iexpids],pch=19,col=mycols[iexpids],bty="n",cex=1.75)}
  # boxplots pss/pod
  par(mar=c(3.95,0,0.15,0.5))
  xdata = NULL
  for(i in iexpids){
    # all land points
    if(plotpss){
      xdata=cbind(xdata,na.omit(c(cvaldata[[varname]][[i]][[10]][['pod']]-cvaldata[[varname]][[i]][[10]][['pofd']])))}
    if(plotpod){
      xdata=cbind(xdata,na.omit(c(100*cvaldata[[varname]][[i]][[10]][['pod']])))}
  }  
  xss=seq(0,1,length.out=4)
  boxplot(at=xss[1:length(iexpids)],xdata, 
  #boxplot(at=seq(0,1,length.out=length(expids))[iexpids],xdata, 
          outline=FALSE, boxwex=boxwex, horizontal=FALSE,axes=FALSE,
          col=adjustcolor(mycols[iexpids],1),boxcol=mycols[iexpids],staplecol=mycols[iexpids],whiskcol=mycols[iexpids],
          ylim=yrange,xlim=c(-0.1,1.1))
  points(xss[1:length(iexpids)],colMeans(xdata,na.rm=T),pch=19)
  # boxplots bias
  par(mar=c(0,4.65,0.5,0.15))
  xdata = NULL
  for(i in iexpids){
    # all land points
    xdata=cbind(xdata,na.omit(c(cvaldata[[varname]][[i]][[10]][['bias']])))
  }
  #boxplot(at=seq(0,1,length.out=length(expids))[iexpids],xdata, 
  boxplot(at=xss[1:length(iexpids)],xdata, 
          outline=FALSE, boxwex=boxwex, horizontal=TRUE,axes=FALSE,
          col=adjustcolor(mycols[iexpids],1),boxcol=mycols[iexpids],staplecol=mycols[iexpids],whiskcol=mycols[iexpids],
          ylim=xrange,xlim=c(-0.1,1.1))
  points(colMeans(xdata,na.rm=T),xss[1:length(iexpids)],pch=19)
  text(labpos,0.85,mtitle,cex=3.75,srt=0,xpd = NA,font=2)#legend(-6,0.95,mtitle,text.font=2,bty="n",cex=2.5)
  # add empty plot for 4th plot
  plot(0,type='n',axes=FALSE,ann=FALSE)
}

  matrixany     = function(x){
      anyx  = array(NA,dim(x)[1:2])
      for (ii in 1:dim(x)[1]){
      for (jj in 1:dim(x)[2]){
      anyx[ii,jj]   = any(x[ii,jj]>0)+0
      }}
      return(anyx)}

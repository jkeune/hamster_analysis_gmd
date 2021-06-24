convert_mm_m3_3d = function(matrix3d,areas2d){
    # ATTN: area unit needs to be checked...
    cmatrix3d       = array(NA,dim(matrix3d))
    # assuming the last dimension is time
    for (it in 1:(dim(matrix3d)[3])){
    cmatrix3d[,,it] = matrix3d[,,it] * areas2d/1e3
    }
return(cmatrix3d)}

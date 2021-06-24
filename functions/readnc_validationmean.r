readnc_validationmean = function(ifile,ret="data"){

    # get filename
    	print(sprintf("%s",ifile))

	if(!file.exists(ifile))	next 
  	# read data
	ncfile	= nc_open(ifile)
	if(ret=="grid"){
		lon	= ncvar_get(ncfile,"lon")
		lat	= ncvar_get(ncfile,"lat")
	}
	if(ret=="data"){
        bias   = ncvar_get(ncfile,"bias")
	      pss    = ncvar_get(ncfile,"pss")
	      pod    = ncvar_get(ncfile,"pod")
	      pofd   = ncvar_get(ncfile,"pofd")
	      acc    = ncvar_get(ncfile,"acc")
	      fbias  = ncvar_get(ncfile,"fbias")
	      odr    = ncvar_get(ncfile,"odr")
	}

if(ret=="grid"){
	return(list(lon=lon,lat=lat))
}
if(ret=="data"){
	return(list(bias=bias,pod=pod,pofd=pofd,pss=pss,acc=acc,fbias=fbias,odr=odr))
}
}




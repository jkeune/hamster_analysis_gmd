#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to calculate contingency table measures and bias
using (merged) hamster output and a reference data set (ERA-Interim)

    module load Python/3.7.4-GCCcore-8.3.0
    module load h5py/2.10.0-intel-2019b-Python-3.7.4
    module load netcdf4-python/1.5.3-intel-2019b-Python-3.7.4

@author: jessica keune, 01-2021
"""

###########################################################################
##--- MODULES
###########################################################################

import numpy as np
import os, fnmatch
import netCDF4 as nc4
import sys
import argparse
import time
import math as math
from datetime import datetime, timedelta, date
from math import sin,cos,acos,atan,atan2,sqrt,floor
from dateutil.relativedelta import relativedelta
import datetime as datetime
import warnings
import csv
import random
import calendar
    
###########################################################################
##--- FUNCTIONS
###########################################################################

def contingency_table(ref,mod,thresh=0):
    # creates a contingency table based on 1D np.arrays
    # ATTN: mod is already binary data, i.e. 1 = detected; 0 = not detected
    ieventobs   = (np.where(ref>thresh)[0])
    ineventobs  = (np.where(ref<=thresh)[0])
    a           = len(np.where(mod[ieventobs]>=1)[0])     # hits
    b           = len(np.where(mod[ineventobs]>=1)[0])    # false alarms
    c           = len(np.where(mod[ieventobs]<1)[0])    # misses
    d           = len(np.where(mod[ineventobs]<1)[0])   # correct negatives
    return({"a":a,"b":b,"c":c,"d":d})
    
def try_div(x,y):
    try: return x/y
    except ZeroDivisionError: return 0
    
def calc_ctab_measures(cdict):
    # calculates common contingency table scores
    # scores following definitions from https://www.cawcr.gov.au/projects/verification/
    a           = cdict["a"]    # hits
    b           = cdict["b"]    # false alarms
    c           = cdict["c"]    # misses
    d           = cdict["d"]    # correct negatives
    # calculate scores
    acc         = try_div(a+d,a+b+c+d)          # accuracy
    far         = try_div(b,a+b)                # false alarm ratio
    fbias       = try_div(a+b,a+c)              # frequency bias
    pod         = try_div(a,a+c)                # probability of detection (hit rate)
    pofd        = try_div(b,b+d)                # probability of false detection (false alarm rate)
    sr          = try_div(a,a+b)                # success ratio
    ts          = try_div(a,a+c+b)              # threat score (critical success index)
    a_random    = try_div((a+c)*(a+b),a+b+c+d)
    ets         = try_div((a-a_random),(a+b+c+a_random)) # equitable threat score (gilbert skill score)
    pss         = pod-pofd                      # peirce's skill score (true skill statistic)
    odr         = try_div(a*d,c*b)              # odd's ratio      
    return({"acc":acc,"far":far,"fbias":fbias,"pod":pod,"pofd":pofd,"sr":sr,"pss":pss,"odr":odr})
    

###########################################################################
##--- MAIN
###########################################################################

# loop over experiment id's and variables
for expid in ["ALLPBL","RH-10-20","SOD08-SCH19","FAS19","SCH20"]:
    for ivar in ["P","E","H"]:
        

      ###########################################################################
      ##--- SETTINGS
      ###########################################################################
        if ivar=="H":
            iavg="daymean"
            thres=1
        else:
            iavg="daysum"
            thres=0.001
        print("Using threshold for "+str(ivar)+" :"+str(thres))

        # hamster file (*_n_part variable)
        mpath="./data/hamster/global/postpro"
        mfile1=str(mpath)+"/"+str(ivar)+"_"+str(expid)+"_"+str(iavg)+"_1980-2016_all.nc"
        mfile2=str(mpath)+"/"+str(ivar)+"_n_part_"+str(expid)+"_daysum_1980-2016_all.nc"
        
        # reference data file
        rpath="./data/erainterim/postpro"
        rfile=str(rpath)+"/"+str(ivar)+"_ERA_1deg_"+str(iavg)+"_1980-2016_all.nc"
        
        # output file
        opath="./data/validation/global"
        if not os.path.exists(opath):
                os.makedirs(opath)
        ofile=str(opath)+"/"+str(ivar)+"_"+str(expid)+"_daily_1980-2016_all_thresh-"+str(thres)+".nc"
        
        ###########################################################################
        ##--- READING AND PROCESSING DATA
        ###########################################################################
        
        print(" Reading hamster data:" +str(mfile2))
        with nc4.Dataset(mfile2, mode='r') as f:
            mvar    = ivar+"_n_part"
            mndata  = np.abs(np.asarray(f[mvar][:]))
            mndata[np.where(mndata>1e6)[0]] = 0
            mndata[np.where(mndata<0)[0]]   = 0
            print(" * hamster data is of shape: " + str(mndata.shape))
            lon     = np.asarray(f['lon'][:])
            lat     = np.asarray(f['lat'][:])
        
        print(" Reading hamster data:" +str(mfile1))
        with nc4.Dataset(mfile1, mode='r') as f:
            mvar    = ivar
            mdata   = np.abs(np.asarray(f[mvar][:]))
            mdata[np.where(mdata>1e6)[0]]   = 0
            mdata[np.where(mdata<0)[0]]     = 0
            print(" * hamster data is of shape: " + str(mdata.shape))
        
        print(" Reading reference data:" +str(rfile))
        with nc4.Dataset(rfile, mode='r') as f:
            rvar    = ivar+"_ERA"
            rdata   = np.abs(np.asarray(f[rvar][:]))
            rdata[np.where(rdata>1e6)[0]]   = 0
            rdata[np.where(rdata<0)[0]]     = 0
            print(" * reference data is of shape: " + str(rdata.shape))
        
        # calculating stats 
        bias= np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        acc = np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        pod = np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        pofd= np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        pss = np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        fbias= np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        odr = np.zeros(shape=(mdata.shape[1],mdata.shape[2]))
        print(" Processing...")
        for y in range(rdata.shape[1]):  
            progress=100*y/(rdata.shape[1]-1)
            if round(progress) in range(10,100,5):
                print(" ..."+str(round(progress))+"%...")
            for x in range(rdata.shape[2]):  
                myctab = calc_ctab_measures(contingency_table(rdata[:,y,x],mndata[:,y,x],thresh=thres))
                acc[y,x] = myctab['acc']
                pod[y,x] = myctab['pod']
                pofd[y,x]= myctab['pofd']
                pss[y,x] = myctab['pss']
                fbias[y,x]= myctab['fbias']
                odr[y,x] = myctab['odr']
                diff     = mdata[:,y,x]-rdata[:,y,x]
                diff[np.where(diff>1e6)[0]]=0
                diff[np.where(diff<-1e6)[0]]=0
                bias[y,x]= np.nanmean(diff)
        
        
        print(" Writing output file: "+str(ofile))
        
        # create netCDF4 instance
        ncf=nc4.Dataset(ofile,'w', format='NETCDF4')
        
        ### create dimensions ###
        ncf.createDimension('lat', lat.size)
        ncf.createDimension('lon', lon.size)
        
        # create grid + time variables
        latitudes           = ncf.createVariable('lat', 'f8', 'lat')
        longitudes          = ncf.createVariable('lon', 'f8', 'lon')
        
        # create variables
        ncacc               = ncf.createVariable('acc', 'f8', ('lat','lon'))
        ncpod               = ncf.createVariable('pod', 'f8', ('lat','lon'))
        ncpofd              = ncf.createVariable('pofd', 'f8', ('lat','lon'))
        ncpss               = ncf.createVariable('pss', 'f8', ('lat','lon'))
        ncodr               = ncf.createVariable('odr', 'f8', ('lat','lon'))
        ncfbias             = ncf.createVariable('fbias', 'f8', ('lat','lon'))
        ncbias              = ncf.createVariable('bias', 'f8', ('lat','lon'))
            
        # set attributes
        ncf.title           = "Validation statistics"
        ncf.description     = "Data used: hamster file = "+ str(mfile1)+" + hamster file = "+str(mfile2)+" + reference file = "+ str(rfile) + " with a threshold of // settings: variable = "+ str(ivar)+" with a threshold of "+ str(thres) + " "
        today               = datetime.datetime.now()
        ncf.history         = "Created " + today.strftime("%d/%m/%Y %H:%M:%S")
        ncf.institution     = "Hydro-Climate Extremes Laboratory (H-CEL), Ghent University, Ghent, Belgium"
        ncf.source          = "Validation statistics for HAMSTER"
        latitudes.units     = 'degrees_north'
        longitudes.units    = 'degrees_east'
        ncpod.units         = ''
        ncpod.long_name     = 'probability of detection (hit rate)'
        ncacc.long_name     = 'accuracy'
        ncbias.long_name    = 'bias'
        ncfbias.long_name   = 'frequency bias'
        ncpofd.long_name    = 'probability of false detection (false alarm rate)'
        ncpss.long_name     = 'peirce´s skill score (true skill statistic)'
        ncodr.long_name     = 'odd`s ratio'
        latitudes[:]        = lat[:]
        longitudes[:]       = lon[:]
        ncodr[:]            = odr[:]
        ncpod[:]            = pod[:]
        ncpss[:]            = pss[:]
        ncpofd[:]           = pofd[:]
        ncacc[:]            = acc[:]
        ncpofd[:]           = pofd[:]
        ncfbias[:]          = fbias[:]
        ncbias[:]           = bias[:]
        
        # close file
        ncf.close()

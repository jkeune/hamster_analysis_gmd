#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# python2.7 

from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()

## output directory
odir = "./data/erainterim/sshf_12hourly"

for year in range(1979,2016):
    print("Downloading year", year)

    outfile = odir+"/"+"H_1deg_"+str(year)+".nc"
    
    ecinput = {
        "class": "ei",
        "dataset": "interim",
        "date": str(year)+"-01-01/to/"+str(year)+"-12-31",
        "expver": "1",
        "grid": "1.0/1.0",
        "time": "00:00:00/12:00:00",
        "step": "12", 
        "levtype": "sfc",
        "param": "146.128",
        "stream": "oper",
        "type": "fc",
        "format": "netcdf",
        "target": outfile,
        }
    print(ecinput)
    server.retrieve(ecinput)

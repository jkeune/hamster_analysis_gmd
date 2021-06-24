#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# python2.7 

from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()

## output directory
odir = "./data/staticdata"

outfile = odir+"/eafc_1x1.nc"

ecinput = {
    "class": "ei",
    "dataset": "interim",
    "date": "2016-01-01/to/2016-01-01",
    "domain": "g",
    "padding": "0",
    "accuracy": "16",
    "expver": "1",
    "grid": "1.0/1.0",
    "time": "00:00:00",
    "levtype": "sfc",
    "repres": "gg",
    "param": "172.128",
    "stream": "oper",
    "type": "an",
    "format": "netcdf",
    "target": outfile,
}
print(ecinput)
server.retrieve(ecinput)

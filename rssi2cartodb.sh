#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2013-04-03
# mail: carlos.rueda@deimos-space.com

import datetime
import time
import os
import sys
import csv


import httplib
import urllib
import urllib2

GPRS_count = 0
UHF_count = 0    

tolerancia = 8203.0

fichero_stadistics = sys.argv[1]
tabla_cartodb = sys.argv[2]

fichero = open(fichero_stadistics, 'rb')
for line in fichero:
    if line.find('TRAMA WMX YOK')>0 :
        UHF_count +=1
        index_separador = line.find(">")
        trama = line[index_separador+1:len(line)]
        box_number = trama[1:4]
        rssi = int(line[56:59])
        rssi_truncado = 0
        if (rssi<70):
            rssi_truncado = 60
        elif (rssi>69 and rssi<80):
            rssi_truncado = 70
        elif (rssi>79 and rssi<90):
            rssi_truncado = 80
        elif (rssi>89 and rssi<100):
            rssi_truncado = 90
        elif (rssi>100):
            rssi_truncado = 100

        dia_llegada = line[1:11]
        hora_llegada = line[12:20]

        indice_lat = trama.find("2013101")
        indice_lon = trama.find(",-")
        lat = trama[indice_lat+7:indice_lon]
        lon = trama[indice_lon+1:indice_lon+10]

        date_cartodb = dia_llegada+"T"+hora_llegada

        url = "http://carlrue.cartodb.com"
        params = "/api/v2/sql?q=INSERT INTO " + tabla_cartodb + " (date, lat, long,rssi) VALUES ('"+date_cartodb+"',"+lat+","+lon+","+str(rssi_truncado)+")&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c"
        print url+params
        urllib.urlopen(url+params)
        
fichero.close


#R107Xxx18:07:0413.11.201310153.225468299999996,-3.0821525999999997,0,0.01,216.6,0107,0300,120,107 ( 88 36 109 -115 -124 -121 15 -96 31 -71 -113 -37 -2 41 -77 106 0 1 84 -100 13 10 13 10 0 0) WHO_SEND:uhf


print ('Tramas WXM: ', UHF_count)
#print ('Tramas GPRS: ', GPRS_count)

# FUNCIONA: carlrue.cartodb.com/api/v2/sql?q=INSERT INTO gprs_grecia (the_geom) VALUES (ST_SetSRID(ST_MakePoint(-3.7, 41.00), 4326))&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c


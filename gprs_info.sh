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

#fichero = open('/opt/KyrosComserver/logs/Stadistics.log', 'rb')
fichero = csv.reader(open('/opt/KyrosComserver/logs/Stadistics.log.2013-06-01_R004', 'rb'))
for index,row in enumerate(fichero):
    parte1 = row[0]
    parte2 = row[1]
    parte3 = row[2]

    hora_llegada = parte1[12:22]

    if parte2.find('TRAMA GPRS con datos correctos')>0 :
        GPRS_count +=1
    elif parte2.find('TRAMA UHF con datos correctos')>0 :
        UHF_count +=1
        parte22 = parte2.split(':')
        parte221 = parte22[1]
        parte222 = parte22[2]
        parte223 = parte22[3]

        hora_trama = parte221[len(parte221)-2:len(parte221)]
        minutos_trama = parte222[len(parte222)-2:len(parte222)]
        segundos_trama = parte223[0:2]
        hora_trama_completa = hora_trama + ":" + minutos_trama + ":" + segundos_trama

        datos = parte2.split('.')
        datos2 = datos[2]
        grados_lat = datos2[len(datos2)-2:len(datos2)]
        lat = grados_lat + "." + datos[3]
        
        datos = parte3.split('.')
        grados_lon = datos[0]
        datos2 = datos[1].split('.')
        min_lon = datos2[0]
        lon = grados_lon + "." + min_lon

        #print ("->" + hora_llegada + " - " + hora_trama_completa + " - " + lat + " - " + lon)
        from datetime import datetime
        fecha1 = datetime.strptime(hora_llegada, '%H:%M:%S')
        fecha2 = datetime.strptime(hora_trama_completa, '%H:%M:%S')
        
        #print ("-->" + str(time.mktime(fecha1.timetuple()) - time.mktime(fecha2.timetuple()) ) )
        if (time.mktime(fecha1.timetuple()) - time.mktime(fecha2.timetuple()) < tolerancia):
            print ("->" + hora_llegada + " - " + hora_trama_completa + " - " + lat + " - " + lon)
            url = "http://carlrue.cartodb.com"
            params = "/api/v2/sql?q=INSERT INTO uhf_grecia_R004 (the_geom) VALUES (ST_SetSRID(ST_MakePoint("+lon+","+lat+"), 4326))&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c"
            urllib.urlopen(url+params)
        else:
            print ("->" + str(time.mktime(fecha1.timetuple()) - time.mktime(fecha2.timetuple()) ) )
        
    

fichero.close

print ('Tramas UHF: ', UHF_count)
print ('Tramas GPRS: ', GPRS_count)

# FUNCIONA: carlrue.cartodb.com/api/v2/sql?q=INSERT INTO gprs_grecia (the_geom) VALUES (ST_SetSRID(ST_MakePoint(-3.7, 41.00), 4326))&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c


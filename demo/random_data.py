from random import randint, randrange

import os

ftemperature = open("temperature", "w")
fhumidity = open("humidity", "w")
fsky = open("sky", "w")

current=randrange(10,30,1)
for i in range(24):
    for j in range(12):
        ftemperature.write(str(i).zfill(2)+":"+str(j*5).zfill(2)+" "+str(current)+"\n")
        factor=0.6 if randint(0,1)==0 else -0.4
        current=round(current+factor, 1)
ftemperature.close()

current=randrange(40,80,1)
for i in range(24):
    for j in range(12):
        fhumidity.write(str(i).zfill(2)+":"+str(j*5).zfill(2)+" "+str(current)+"\n")
        factor=0.6 if randint(0,1)==0 else -0.4
        current=round(current+factor, 1)
fhumidity.close()

names=["Clear", "Clouds", "Rain", "Thunderstorm", "Snow", "Drizzle", "Atmosphere"]
icons=[ 
    ["01d","01n"],
    ["02d","02n","03d","03n","04d","04n"], 
    ["09d","09n","10d","10n","13d","13n"],
    ["11d","11n"], 
    ["13d","13n"],
    ["09d","09n"],
    ["50d","50n"]
]
for i in range(24):
    index=randint(0,len(names)-1)
    icon=icons[index][randint(0,len(icons[index])-1)]
    fsky.write(str(i).zfill(2)+":00 "+names[index]+" "+icon+"\n")
fsky.close()
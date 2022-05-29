#!/bin/sh

temperature_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' temperature`
temperature_max=`awk 'BEGIN{x=0} {if($2>x) x=$2} END{print x}' temperature`

humidity_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' humidity`
humidity_max=`awk 'BEGIN{x=0} {if($2>x) x=$2} END{print x}' humidity`

global=`awk 'BEGIN{x=0} {arr[$2]++} {for(key in arr) if(x<arr[key]) k=key; x=arr[key]} END{print k}' sky`
 
#echo $temperature_min
#echo $temperature_max
#echo $humidity_min
#echo $humidity_max
#echo $global

cat <<EOT >> temperature.p
reset
clear
set title 'temperature'
set terminal png size 800,500

set xdata time
set format x '%H:%M'
set timefmt '%H:%M'

set xrange ['00:00':*]
set yrange [14:19]

set xtics rotate
set output 'graph/temperature_graph.png'
plot 'temperature' using 1:2 with lines
EOT

cat <<EOT >> humidity.p
EOT

cat <<EOT >> sky.p
EOT

gnuplot temperature.p
gnuplot humidity.p
gnuplot sky.p

rm -f temperature.p
rm -f humidity.p
rm -f sky.p
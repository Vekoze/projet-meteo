#!/bin/sh

temperature_min=14.4
temperature_max=18.6

humidity_min=49.9
humidity_max=58.8

global="Clear"

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
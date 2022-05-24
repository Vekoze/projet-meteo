#!/bin/sh

echo "set terminal png size 800,500 enhanced background rgb 'white'" > temperature_gnuplot
echo "set title 'temperature'" >> temperature_gnuplot
echo "set xr [00:00:00:00]" >> temperature_gnuplot
echo "set yr [$temperature_min:$temperature_max]" >> temperature_gnuplot
echo "set output 'temperature_graph.png'" >> temperature_gnuplot

gnuplot temperature_gnuplot
gnuplot humidity_gnuplot
gnuplot sky_gnuplot

rm -f temperature_gnuplot
rm -f humidity_gnuplot
rm -f sky_gnuplot
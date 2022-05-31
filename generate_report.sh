#!/bin/sh

readonly WEATHER_PATH="$HOME/weather.json"

get_json_value(){
    local key=$1
    awk -v path=$key -f json.awk $WEATHER_PATH
}

float_to_int(){
    printf "%.0f" $1
}

temperature_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' temperature`
temperature_max=`awk 'BEGIN{x=0} {if($2>x) x=$2} END{print x}' temperature`
humidity_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' humidity`
humidity_max=`awk 'BEGIN{x=0} {if($2>x) x=$2} END{print x}' humidity`
global=`awk 'BEGIN{x=0} {arr[$2]++} {for(key in arr) if(x<arr[key]) k=key; x=arr[key]} END{print k}' sky`

city=$(get_json_value "name")
lon=$(get_json_value "coord.lon")
lat=$(get_json_value "coord.lat")
date=`date +%d-%m-%Y`

mkdir -p graph
cat <<EOT >> temperature.p
set title 'temperatures'
set terminal png size 1000,350
set xdata time
set format x '%H:%M'
set timefmt '%H:%M'
set xrange ['00:00':*]
set yrange [$(float_to_int $temperature_min):$(float_to_int $temperature_max)]
set grid
set ytics 0.5
set xtics rotate
set key off
set output 'graph/temperature.png'
plot 'temperature' using 1:2 with lines
EOT

cat <<EOT >> humidity.p
set title 'humidite'
set terminal png size 1000,350
set xdata time
set format x '%H:%M'
set timefmt '%H:%M'
set xrange ['00:00':*]
set yrange [$(float_to_int $humidity_min):$(float_to_int $humidity_max)]
set grid
set ytics 0.5
set xtics rotate
set key off
set output 'graph/humidity.png'
plot 'humidity' using 1:2 with lines
EOT

cat <<EOT >> sky.p
set terminal png size 1300,150
set output 'graph/sky.png'

set xtics font ", 8"
unset ytics

set xdata time
set format x '%H:%M'
set timefmt '%H:%M'

set xtics ()
set for [i=0:24:2] xtics add (sprintf("%3.0f:00", i%24) i*100)

set xrange [0:2400]
set yrange [0:100]

set macros
begin="binary filetype=png"
end="dx=1 dy=0.3 with rgbalpha notitle"
EOT

i=0
while [ $i -ne 24 ]
do
    line=`expr $i + 1`
    icon=$( sed -n "$line"p sky | awk '{print $3}' )
    if [ $i -eq 0 ];then echo -n "plot " >> sky.p; fi
    x=`expr $i \* 100`
    echo -n "'ressource/$icon.png' @begin origin=($x,35) @end" >> sky.p
    if [ $i -ne 23 ];then echo ", \\" >> sky.p ;fi
    i=$(($i+1))
done

gnuplot temperature.p
gnuplot humidity.p
gnuplot sky.p

> report.md
cat << EOT >> report.md
\pagenumbering{gobble}

---
header-includes: |
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyhead[L]{Rapport métérologique de $city}
    \fancyhead[R]{$date}
...

# Rapport métérologique de $city

**Jour**: $date

**Emplacement**: $city ($lat°N,$lon°W)

## Ciel

![](graph/sky.png "Ciel")

- **global**: $global

## Température

![](graph/temperature.png "Temperature")

- **température min**: $temperature_min
- **température max**: $temperature_max

## Humidité

![](graph/humidity.png "Humidite")

- **humidité min**: $humidity_min
- **humidité max**: $humidity_max
EOT

pandoc -V geometry:margin=1.2in -s -o report.pdf report.md

# Cleanup

rm -f temperature.p
rm -f humidity.p
rm -f sky.p

rm -f report.md

#rm -f temperature
#rm -f humidity
#rm -f sky

#rm graph/*.png
#rmdir graph

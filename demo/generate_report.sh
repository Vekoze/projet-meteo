#!/bin/sh

get_json_value(){
    local key=$1
    awk -v path=$key -f json.awk weather.json
}

round_upper(){
    echo "$1+1" | bc
}

export LC_NUMERIC=en_US.utf-8
temperature_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' temperature`
temperature_max=`awk 'BEGIN{max=0} { if(max < $2) max = $2 } END{print max}' temperature`
humidity_min=`awk 'BEGIN{x=99} {if($2<x) x=$2} END{print x}' humidity`
humidity_max=`awk 'BEGIN{x=0} {if($2>x) x=$2} END{print x}' humidity`
global=`awk 'BEGIN{x=0} {arr[$2]++} {for(key in arr) if(x<arr[key]) k=key; x=arr[key]} END{print k}' sky`

city=$(get_json_value "name")
lon=$(get_json_value "coord.lon")
lat=$(get_json_value "coord.lat")
date=`date +%d-%m-%Y`

cat <<EOT >> temperature.p
set title 'temperatures'
set terminal png size 1000,350
set xdata time
set format x '%H:%M'
set timefmt '%H:%M'
set xrange ['00:00':*]
set yrange [$(round_upper $temperature_min):$(round_upper $temperature_max)]
set grid
set xtics rotate
set key off
set output 'graph_temperature.png'
plot 'temperature' using 1:2 with lines
EOT

cat <<EOT >> humidity.p
set title 'humidite'
set terminal png size 1000,350
set xdata time
set format x '%H:%M'
set timefmt '%H:%M'
set xrange ['00:00':*]
set yrange [$(round_upper $humidity_min):$(round_upper $humidity_max)]
set grid
set xtics rotate
set key off
set output 'graph_humidity.png'
plot 'humidity' using 1:2 with lines
EOT

cat <<EOT >> sky.p
set terminal png size 1300,150
set output 'graph_sky.png'
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

![](graph_sky.png "Ciel")

- **global**: $global

## Température

![](graph_temperature.png "Temperature")

- **température min**: $temperature_min
- **température max**: $temperature_max

## Humidité

![](graph_humidity.png "Humidite")

- **humidité min**: $humidity_min
- **humidité max**: $humidity_max
EOT

pandoc -V geometry:margin=1.2in -s -o rapport_meteo_enjalbert_$date.pdf report.md

# Cleanup

rm -f temperature.p
rm -f humidity.p
rm -f sky.p

rm -f report.md

rm -f temperature
rm -f humidity
rm -f sky

rm -f graph_temperature.png
rm -f graph_humidity.png
rm -f graph_sky.png

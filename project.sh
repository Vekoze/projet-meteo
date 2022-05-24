#!/bin/sh

readonly WEATHER_PATH="$HOME/weather.json"

fetch_weather_file(){ 
    scp -i ~/.ssh/id_rsa.pub venjal24@10.30.48.100:/tmp/weather.json $WEATHER_PATH
}

get_json_value(){
    local key=$1
    awk -v path=$key -f json.awk $WEATHER_PATH
}

get_hour(){
    echo $(date +%H)
}

get_time(){
    echo $(date +%H:%M)
}

kelvin_to_celsius(){
    local input=$1
    readonly K=273.15
    echo $input-$K | bc
}

fetch_weather_file

temperature=$(kelvin_to_celsius $(get_json_value "main.temp"))
humidity=$(get_json_value "main.humidity")
sky=$(get_json_value "weather.main")

time=$(get_time)
hour=$(get_hour)

if [ $hour -eq 0 ]
then
    > temperature
    > humidity
    > sky
fi

if [ -f temperature ]; then > temperature; fi
if [ -f humidity ]; then > humidity; fi
if [ -f sky ]; then > sky; fi

printf "%s %s\n" $time $temperature >> temperature
printf "%s %s\n" $time $humidity >> humidity
printf "%s %s\n" $time $sky >> sky

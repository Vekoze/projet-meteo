#!/bin/sh

readonly WEATHER_PATH="$HOME/weather.json"

fetch_weather_file(){ 
    scp -i ~/.ssh/id_rsa.pub venjal24@10.30.48.100:/tmp/weather.json $WEATHER_PATH
}

get_json_value(){
    local key=$1
    awk -v path=$key -f $HOME/json.awk $WEATHER_PATH
}

get_minute(){
    echo $(date +%M)
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
sky_icon=$(get_json_value "weather.icon")

time=$(get_time)
hour=$(get_hour)
minute=$(get_minute)

printf "%s %s\n" $time $temperature >> temperature
printf "%s %s\n" $time $humidity >> humidity
if [ $minute -eq 0 ]; then printf "%s %s\n" $time $sky $sky_icon >> sky; fi
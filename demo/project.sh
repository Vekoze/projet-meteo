#!/bin/sh

get_json_value(){
    local key=$1
    awk -v path=$key -f json.awk weather.json
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

scp venjal24@10.30.48.100:/tmp/weather.json weather.json

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

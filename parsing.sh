#!/bin/sh

weather_path="$HOME/weather.json"

fetch_weather_file(){ 
    scp -i ~/.ssh/id_rsa.pub venjal24@10.30.48.100:/tmp/weather.json $weather_path
}

get_value(){
    key=$1
    grep -P -o '(?<="$key":)(\d*[.]\d*)' $HOME/weather.json
}

k_to_c(){
    input=$1
    readonly K=273.15
    echo $input-$K | bc   
}

#get_value "temp"

#fetch_weather_file

$(sed 's/\]//g ; s/\[//g ; s/\"[a-zA-Z]*\":{//g ; s/[{"}]//g ; s/,/\n/g' $weather_path)


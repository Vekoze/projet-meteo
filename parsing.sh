#!/bin/sh

readonly WEATHER_PATH="$HOME/weather.json"

fetch_weather_file(){ 
    scp -i ~/.ssh/id_rsa.pub venjal24@10.30.48.100:/tmp/weather.json $WEATHER_PATH
}

get_value(){
    local key=$1
    awk -v path=$key -f json.awk $WEATHER_PATH
}

get_minutes(){
    echo $(date +%M)
}

get_hours(){
    echo $(date +%H)
}

k_to_c(){
    local input=$1
    readonly K=273.15
    echo $input-$K | bc   
}

fwrite(){
    local file=$3
    printf "| %-6s| %-9s|\n" $1 $2 >> $file
}

get_mean(){
    local file=$1
    echo `cat $file | egrep -o "[0-9]+(\.[0-9]+)" | tail -1`
}

get_new_mean(){
    local file=$1
    local new_value=$2

    local last_n=$(($n-1))   
    local last_mean=$(get_mean $file)
    
    local old_values=$( echo $last_mean*$last_n | bc )
    local new_values=$( echo $old_values+$new_value | bc)
     
    if [ ! $n -eq 0 ]
    then
        echo $( echo $new_values/$n | bc)
    else
        echo $new_value
    fi
}

create_if_not_exists(){
    local file=$1
    
    if [ ! -f $file ] 
    then
        touch $file
    fi
}

#fetch_weather_file

temperature=$(k_to_c $(get_value "main.temp"))
humidity=$(get_value "main.humidity")
sky=$(get_value "weather.main")

minutes=$(get_minutes | bc)
hours=$(get_hours | bc)

n=$( echo $minutes/5 | bc )

create_if_not_exists temperature
create_if_not_exists humidity
create_if_not_exists sky

echo "## Température\n" >> temperature
echo "| Heure | Température |" >> temperature
echo "|-------|-------------|" >> temperature

echo "## Humidité\n" >> humidity
echo "| Heure | Humidité |" >> humidity
echo "|-------|----------|" >> humidity

echo "## Ciel\n" >> sky
echo "| Heure | Ciel |" >> sky
echo "|-------|------|" >> sky

temp_mean=$(get_new_mean temperature $temperature)
humidity_mean=$(get_new_mean humidity $humidity)

if [ $n -eq 0 ]
then
    fwrite $hours $sky sky
fi

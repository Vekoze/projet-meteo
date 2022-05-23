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

fwrite_temperature(){
    local file=$3
    printf "| %-6s| %-12s|\n" $1 $2 >> $file
}

fwrite_humidity(){
    local file=$3
    printf "| %-6s| %-9s|\n" $1 $2 >> $file
}

fwrite_sky(){
    local file=$3
    printf "| %-6s| %-5s|\n" $1 $2 >> $file
}

get_current_mean(){
    local file=$1
    echo `cat $file | egrep -o "[0-9]+(\.[0-9]+)" | tail -1`
}

get_new_mean(){
    local file=$1
    local new_value=$2

    if [ $n -ne 1 ]
    then
        local last_n=$(($n-1))
        local last_mean=$(get_current_mean $file)

        local old_values=$( echo $last_mean*$last_n | bc )
        local new_values=$( echo $old_values+$new_value | bc)

        echo $( echo "scale=1; $new_values / $n" | bc)
    else
        echo $new_value
    fi
}

#fetch_weather_file

temperature=$(k_to_c $(get_value "main.temp"))
humidity=$(get_value "main.humidity")
sky=$(get_value "weather.main")

minutes=$(get_minutes | bc)
hours=$(get_hours | bc)

n=$( echo $minutes/5 + 1 | bc )

if [ ! -f temperature ] 
then
    touch temperature
    printf "\n## Température\n" >> temperature
    printf "| Heure | Température |\n" >> temperature
    printf "|-------|-------------|\n" >> temperature
fi

if [ ! -f humidity ] 
then
    touch humidity
    printf "\n## Humidité\n" >> humidity
    printf "| Heure | Humidité |\n" >> humidity
    printf "|-------|----------|\n" >> humidity
fi

if [ ! -f sky ] 
then
    touch sky
    printf "\n## Ciel\n" >> sky
    printf "| Heure | Ciel |\n" >> sky
    printf "|-------|------|\n" >> sky
fi

new_mean_temperature=$(get_new_mean temperature $temperature)
new_mean_humidity=$(get_new_mean humidity $humidity)

if [ $n -eq 1 ]
then
    fwrite_temperature $hours $new_mean_temperature temperature
    fwrite_humidity $hours $new_mean_humidity humidity
    fwrite_sky $hours $sky sky
else
    #sed -i '$ d' temperature
    fwrite_temperature $hours $new_mean_temperature temperature

    #sed -i '$ d' humidity
    fwrite_humidity $hours $new_mean_humidity humidity
fi
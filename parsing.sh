#!/bin/sh

k_to_c(){
    input=$1
    readonly K=273.15
    echo $input-$K | bc   
}

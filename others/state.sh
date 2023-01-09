#!/bin/bash

if [ "$1" == "cmp" ]; then
    ls -a > tmp.txt
    diff tmp.txt state.txt 
    rm tmp.txt
elif [ "$1" == "create" ]; then
    ls -a > state.txt
    date >> state.txt
else
    echo "Usage: ,state [create|cmp]"
fi

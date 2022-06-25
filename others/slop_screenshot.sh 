#!/bin/bash

# Dependencies:
# - slop

screen_shot=$(date '+Screenshot@%Y-%m-%d_%H:%M:%S')
if [ "$1" == "-full" ]; then 
    import -window root ~/pictures/screenshots/$screen_shot.png
elif [ "$1" == "-crop" ]; then
    slop=$(slop -k -f "%g") || exit 1
    read -r G < <(echo $slop)
    import -window root -crop $G ~/pictures/screenshots/$screen_shot.png
fi
notify-send "$screen_shot"

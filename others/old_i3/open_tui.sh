#!/bin/bash
tool=$1
loc="$2"
loc=${loc#"file://"}

if [[ ! -e $loc ]]; then
    loc=$(dirname "$loc")
fi

# notify-send "Debug"
i3-msg exec 'kitty --single-instance '$tool' "'$loc'"'

# https://github.com/ranger/ranger/wiki/Open-Ranger-from-Desktop

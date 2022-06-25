#!/bin/bash

# Get active audio source index
CURRENT_SOURCE=$(pactl info | grep "Default Source" | cut -f3 -d" ")

# Get default device data
DEV_DATA=$(pactl list sources | grep -B 2 -A 10 $CURRENT_SOURCE) 

# Get default device index
DEV_INDEX=$(echo $DEV_DATA | cut -f2 -d" ")

# Toggle DEV_INDEX source muted
pactl set-source-mute ${DEV_INDEX:1} toggle

# Get default device description
DEV_DESCRIPTION=$(echo "$DEV_DATA" | grep "Description" | cut -f2 -d":")

# Get if default device is muted
IS_MUTED=$( echo "$DEV_DATA" | grep "Mute: yes") 

# Decide witch notification to send
if [ -z "$IS_MUTED" ]; then
    notify-send -t 1000 -u critical --app-name="toggle_mic" "MUTED " "${DEV_DESCRIPTION:1}"
else
    notify-send -t 1000 --app-name="toggle_mic" "UNMUTED " "${DEV_DESCRIPTION:1}"
fi

#  

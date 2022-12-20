#!/bin/bash

PADDING=0

while read -r height; read -r width; do
    DISPLAY_HEIGHT=$height
    DISPLAY_WIDTH=$width
done < <(swaymsg -t get_outputs | jaq -rc '.[0] | .rect | .height, .width')

while read -r height; read -r width; do
    HEIGHT=$height
    WIDTH=$width
done < <(swaymsg -t get_tree | jaq -rc '.. | select(.type?) | select(.focused==true) | .rect | .height, .width')

case "$1" in
    "1") NEW_X=0 ; NEW_Y=$((DISPLAY_HEIGHT - HEIGHT - PADDING)) ;;
    "2") NEW_X=$((DISPLAY_WIDTH / 2 - WIDTH / 2)) ; NEW_Y=$((DISPLAY_HEIGHT - HEIGHT - PADDING)) ;;
    "3") NEW_X=$((DISPLAY_WIDTH - WIDTH - PADDING)) ; NEW_Y=$((DISPLAY_HEIGHT - HEIGHT - PADDING)) ;;
    "4") NEW_X=0 ; NEW_Y=$((DISPLAY_HEIGHT / 2 - HEIGHT / 2)) ;;
    "5") NEW_X=$((DISPLAY_WIDTH / 2 - WIDTH / 2)) ; NEW_Y=$((DISPLAY_HEIGHT / 2 - HEIGHT / 2)) ;;
    "6") NEW_X=$((DISPLAY_WIDTH - WIDTH - PADDING)) ; NEW_Y=$((DISPLAY_HEIGHT / 2 - HEIGHT / 2)) ;;
    "7") NEW_X=0 ; NEW_Y=0 ;;
    "8") NEW_X=$((DISPLAY_WIDTH / 2 - WIDTH / 2)) ; NEW_Y=0 ;;
    "9") NEW_X=$((DISPLAY_WIDTH - WIDTH - PADDING)) ; NEW_Y=0 ;;
    *) exit 1 ;;
esac

swaymsg move absolute position "$NEW_X" "$NEW_Y"

# For xorg --

# eval "$(xdotool getwindowfocus getdisplaygeometry --shell)"
# DISPLAY_WIDTH=$WIDTH
# DISPLAY_HEIGHT=$HEIGHT
# eval "$(xdotool getwindowfocus getwindowgeometry --shell)"

# ~ switch-case ~ 

# i3-msg move position "$NEW_X" "$NEW_Y"

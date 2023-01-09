#!/bin/bash

PADDING=2

eval "$(xdotool getwindowfocus getdisplaygeometry --shell)"
DISPLAY_WIDTH=$WIDTH
DISPLAY_HEIGHT=$HEIGHT
eval "$(xdotool getwindowfocus getwindowgeometry --shell)"

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

i3-msg move position "$NEW_X" "$NEW_Y"

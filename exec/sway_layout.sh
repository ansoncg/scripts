#!/bin/bash

swaymsg input "1133:45890:Keyboard_K380_Keyboard" xkb_switch_layout next
new_layout=$(swaymsg -t get_inputs |  jq '.[] | select(.identifier=="1133:45890:Keyboard_K380_Keyboard") | .xkb_active_layout_name')
notify-send -t 1000 "Keyboard layout changed" "$new_layout"

#!/bin/bash

if [ "$(swaymsg -t get_outputs | grep -c  name)" == "2" ] ; then
    swaymsg output eDP-1 disable
    swaymsg output HDMI-A-2 pos 0 0 res 1920x1080
fi

"$SCRIPTS_PATH"/kb_auto_connect.sh

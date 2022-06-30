#!/bin/bash

if [ $(xrandr --query | grep -c " connected") == "2" ] ; then
    xrandr --output eDP1 --mode 1366x768 --pos 1920x0 --rotate normal --output DP1 --off --output HDMI1 --off --output HDMI2 --primary --mode 1920x1080 --pos 0x0 --rotate normal
else
    xrandr --output eDP1 --mode 1366x768 --rotate normal
fi

xset r rate 300 50
nitrogen --restore > /dev/null 2>&1
exec $SCRIPTS_PATH/launch_polybar.sh > /dev/null 2>&1

setxkbmap us
setxkbmap -option caps:none ; xmodmap -e "keycode 66 = copyright"

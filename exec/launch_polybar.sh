#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if [ $(xrandr --query | grep -c " connected") == "2" ] ; then
    polybar -c $HOME/.config/polybar/config.ini mybar &
    polybar -c $HOME/.config/polybar/config.ini secondary &
else
    polybar -c $HOME/.config/polybar/config.ini mybar &
fi

echo "Polybar launched..."

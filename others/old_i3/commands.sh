#!/bin/bash

# Some commands to use with kdenlive

case "$1" in 
    unclutter_off)
        killall unclutter
        ;;
    zoom_in)
        xdotool key Ctrl+Shift+plus
        ;;
    zoom_out)
        xdotool key Ctrl+Shift+minus
        ;;
    i3_next_workspace)
        i3-msg workspace next
        ;;
    i3_prev_workspace)
        i3-msg workspace prev
        ;;
    i3_show_scratchpad)
        i3-msg scratchpad show
        ;;
    *)
        ;;
esac

#!/bin/bash

# Screenshot handler for sway

# Dependencies:
# - grim
# - slurp
# - swappy
# - notifications

full_screenshot() {
    name=$(date '+screenshot@%F_%H-%M-%S').png
    path=$HOME/pictures/screenshots/$name
    grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" "$path"
    notify-send "Full screen captured" "$name"
}

region_screenshot() {
    name=$(date '+screenshot@%F_%H-%M-%S').png
    path=$HOME/pictures/screenshots/$name
    out=$( (grim -g "$(slurp)" - | swappy -f - -o "$path") 2>&1)
    if [ "$out" ] ; then
        notify-send "Region screen capture" "Capture was cancelled"
    else
        notify-send "Region screen captured" "$name"
    fi
}

show_help() {
        printf "\
Screenshot handler for sway
Options:
    -f, --full      Current display full screenshot 
    -r, --region    Region plus edit screenshot
    -h, --help      Show this help
"
}

case "$1" in
    -f|--full)
        full_screenshot
        ;;
    -r|--region)
        region_screenshot
        ;;
    -h|--help)
        show_help
        ;;
    *)
        show_help
        ;;
esac

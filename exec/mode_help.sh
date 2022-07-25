#!/bin/bash

# Dependencies:
# - Dunst

display_help() {
    notify-send --expire-time=15000 "$1" "$(printf "$2")"
}

power() {
display_help "Power mode" "\
Shutdown - Super+F1
Exit i3 - Super+F2 
Reboot - Super+F3
Lock - Super+F4
"
}

MPD() {
display_help "MPD mode" "\
Toggle play - F9/Space 
Next song - F10/n 
Previous song - F8/p
Start - Enter
Stop - s
Repeat - r
Seek - l/h
Lofi - Shitf+l
"
}

launch() {
display_help "Launch mode" "\
Kitty single - Enter
Arandr - a
Droidcam - d
Firefox - f
Gimp - g
Keepassxc - k
i3lock - l
OBS - o
Pavucontrol - p
Steam mini - s
Webcam (qvidcap) - w
Zathura - z
Kitty full - Shift+Enter
Steam full - Shitf+s
"
}

command_func() {
display_help "Command mode" "\
Connect K380 - k
Connect JBL T450 - j
Connect TWS - t
Config K380 - Shift+k
Auto xrandr - x
"
}

resize() {
display_help "Resize mode" "\
Big resize - h/j/k/l
Small resize - arrows
Twitch resize - t
"
}

declare -A MODES
MODES[power]=power
MODES[MPD]=MPD
MODES[launch]=launch
MODES[command]=command_func
MODES[resize]=resize

${MODES[$1]}

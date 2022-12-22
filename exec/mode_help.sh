#!/bin/bash

# Dependencies:
# - Dunst

display_help() {
	notify-send --expire-time=15000 "$1" "$(printf "%s" "$2")"
}

default() {
	display_help "Modes shortcuts" "\
Launch - Ctrl+Super+l
MPD - Ctrl+Super+m
Mouse - Ctrl+.
Numpad move - Ctrl+Super+n 
Power - Ctrl+Super+p
Resize - Ctrl+r
"
}

power() {
	display_help "Power mode" "\
Shutdown - 1
Exit session - 2 
Reboot - 3
Idle lock - 4
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
Kitty full - Shift+Enter
Firefox - f
Keepassxc - k
Swaylock - l
Telegram - t
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
MODES[resize]=resize
MODES[default]=default

${MODES[$1]}

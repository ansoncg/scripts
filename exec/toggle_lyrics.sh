#!/bin/bash

# Toggle lyrics for waybar
# sptlrx for the lyrics (for now) TODO

state=on
toggle_state() {
	trap 'kill "${child}"' SIGUSR1
	case $state in
	"off")
		[ $first_exec == 1 ] || notify-send -t 1500 "Music" "Lyrics on"
		state=on
		sptlrx pipe &
		child="$!"
		wait "${child}"
		;;
	"on")
        [ $first_exec == 1 ] || notify-send -t 1500 "Music" "Lyrics off"
		state=off
		echo ""
		sleep infinity &
		child="$!"
		wait "${child}"
		;;
	esac
    first_exec=0
	toggle_state
}
first_exec=1
toggle_state

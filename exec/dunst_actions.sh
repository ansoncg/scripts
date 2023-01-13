#!/bin/bash

# Dependencies:
# - pipewire-pulse

sound_path="$HOME"/etc/sound/

set_notification_vol() {
	current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}')
	current_volume=${current_volume::-1}

	if ((current_volume > 90)); then
		n_volume=0.15
	elif ((current_volume > 75)); then
		n_volume=0.25
	elif ((current_volume > 50)); then
		n_volume=0.5
	elif ((current_volume > 25)); then
		n_volume=1
	else
		n_volume=2
	fi
}

play_sound() {
	set_notification_vol
	pw-play --volume "$n_volume" "$sound_path""$1" &
}

case "$1" in
"Firefox")
	play_sound "dino_mail.ogg"
	;;
"telegramdesktop")
	play_sound "msn.ogg"
	;;
*)
	echo "Exec: $1 | Title: $2 | Msg: $3" >>~/etc/dunst_new.log
	;;
esac

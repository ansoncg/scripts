#!/bin/bash

# Dependencies:
# - MPD
# - MPC

case "$1" in
"lofi")
	manifest=$(yt-dlp -g "https://www.youtube.com/watch?v=jfKfPfyJRdk")
	mpc insert "$manifest"
	notify-send -t 2000 "MPD" "Lo-fi queued"
	;;
"radio89")
    # https://playerservices.streamtheworld.com/api/livestream-redirect/RADIO_89FM_ADP.aac?dist=site-89fm
	mpc insert "https://21933.live.streamtheworld.com/RADIO_89FM_ADP.aac?dist=site-89fm"
	notify-send -t 2000 "MPD" "Radio 89 queued"
	;;
esac

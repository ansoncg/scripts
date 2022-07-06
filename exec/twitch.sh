#!/bin/bash

# Dependencies:
# - fzf
# - live script

play_stream() {
    streamlink --quiet -p mpv -a '--cache=yes --demuxer-max-bytes=100M' https://www.twitch.tv/"$stream" "$quality" 2>/dev/null &
    chatterino -c "$stream" 2>/dev/null &
}

stream=$1
quality=$2

if [ -z "$quality" ]; then
    quality="best"
fi

if [ -z "$stream" ]; then
    stream=$("$SCRIPTS_PATH"/live.py | fzf  \
    --border=sharp \
    --header="Twitch launcher" \
    --header-first \
    --cycle --info=inline \
    | cut -d " " -f1)
fi

if [ "$stream" ]; then
    play_stream "$stream"
    printf "Starting '%s' stream.\n" "$stream"
fi

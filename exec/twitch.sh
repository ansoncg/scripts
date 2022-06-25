#!/bin/bash

qlty=$2
if [ "$qlty" = "" ]; then
    qlty="best"
fi

streamlink --quiet -p mpv -a '--cache=yes --demuxer-max-bytes=100M' https://www.twitch.tv/"$1" $qlty 2>/dev/null &
chatterino -c "$1" 2>/dev/null &

#!/bin/bash

if [ "$1" == "pause" ]; then
    echo cycle pause | socat - "/tmp/mpvsocket"
elif [ "$1" == "next" ]; then
    echo playlist-next | socat - "/tmp/mpvsocket"
elif [ "$1" == "prev" ]; then
    echo playlist-prev | socat - "/tmp/mpvsocket"
fi

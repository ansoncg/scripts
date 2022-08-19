#!/bin/bash

# song=$(mpc list title | fzf)
song=$(mpc listall | \
    fzf \
    --border=sharp \
    --header="Music launcher" \
    --header-first \
    --cycle --info=inline \
    --margin=0,0,0,0 \
    --padding=0,0,0,1 \
    --height=50%  \
    --multi 
)

if [ "$song" != "" ]; then
    mpc insert "$song"
    mpc next
    mpc play
    # mpc searchplay "$song"
fi
# mpc search title "$song" | mpc add

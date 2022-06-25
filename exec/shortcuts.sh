#!/bin/bash

DIR="/home/anderson/files/notes/shortcuts/"
NAME=$1
FILE="$NAME.md"
OPEN="$DIR$FILE"

if [ -z "$NAME" ]; then
    FILE=$(ls $DIR |
    fzf \
    --border=sharp \
    --header="Software launcher" \
    --header-first \
    --cycle --info=inline \
    --margin=0,49%,0,0 \
    --padding=0,0,0,1 \
    --height=50%  \
    --multi)
    if [ -z "$FILE" ]; then
        exit
    fi
    OPEN="$DIR$FILE"
fi
bat --theme=Dracula --paging=always --color=always --style=grid,numbers $OPEN

#!/bin/bash

# Dependencies:
# - fzf
# - bat

DIR="$HOME/files/notes/shortcuts/"
NAME=$1
FILE="$NAME.md"
OPEN="$DIR$FILE"

if [ -z "$NAME" ]; then
    FILE=$(ls $DIR |
    fzf \
    --border=sharp \
    --header="Shortcut viewer" \
    --header-first \
    --cycle --info=inline \
    --padding=0,0,0,1 \
    --preview="bat --theme=Dracula --paging=always --color=always --style=grid $DIR/{}" \
    --preview-window=right:70% \
    --multi)
    if [ -z "$FILE" ]; then
        exit
    fi
    OPEN="$DIR$FILE"
fi
bat --theme=Dracula --paging=always --color=always --style=grid,numbers $OPEN

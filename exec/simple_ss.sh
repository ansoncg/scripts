#!/bin/bash

# Simple full screen capture. Use flameshot for more features.

screen_shot=$(date '+screenshot@%F_%H-%M-%S')
import -window root $HOME/pictures/screenshots/$screen_shot.png
notify-send "Full screen captured" "$screen_shot.png"

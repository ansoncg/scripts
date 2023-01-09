#!/bin/bash
#
# dual-dual
swaymsg output eDP-1 pos 1920 0 res 1366x768
swaymsg output HDMI-A-2 pos 0 0 res 1920x1080

# dual-single
swaymsg output eDP-1 disable
swaymsg output HDMI-A-2 pos 0 0 res 1920x1080

# single
swaymsg output eDP-1 pos 1920 0 res 1366x768

#!/bin/bash

window_ID=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
window_PID=$(xprop -id $window_ID | awk '/_NET_WM_PID\(CARDINAL\)/{print $NF}')
window_CLASS=$(xprop -id $window_ID | awk '/WM_CLASS/{print $NF}')
kill -9 $window_PID
notify-send -u critical "SIGKILL on $window_CLASS"

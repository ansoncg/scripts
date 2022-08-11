#!/bin/bash

# This scrip runs after i3 starts

# F4:73:35:5D:08:5E
# 5A:83:A2:99:2F:51

info=$(printf "select 00:1A:7D:DA:71:13\ninfo F4:73:35:5D:08:5E\n" | bluetoothctl | grep "Connected: yes") 
while [ -z "$info" ]; do
    printf "select 00:1A:7D:DA:71:13\nconnect F4:73:35:5D:08:5E\n" | bluetoothctl
    sleep 3
    info=$(printf "select 00:1A:7D:DA:71:13\ninfo F4:73:35:5D:08:5E\n" | bluetoothctl | grep "Connected: yes") 
done

notify-send "k380 connected"
$SCRIPTS_PATH/peripherals_config.sh -kb k380

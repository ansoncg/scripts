#!/bin/bash

# F4:73:35:5D:08:5E
# 5A:83:A2:99:2F:51

info=$(printf "select 00:1A:7D:DA:71:13\ninfo F4:73:35:5D:08:5E\n" | bluetoothctl | grep "Connected: yes") 
while [ -z "$info" ]; do
    printf "select 00:1A:7D:DA:71:13\nconnect F4:73:35:5D:08:5E\n" | bluetoothctl
    sleep 10
    info=$(printf "select 00:1A:7D:DA:71:13\ninfo F4:73:35:5D:08:5E\n" | bluetoothctl | grep "Connected: yes") 

    x=$(xrandr 2>&1)
    if [ "$x" != "Can't open display " ]; then
        break
    fi
done

printf "$(date)\nauto_connect.sh: Bluetooth connectd\n\n" >> $HOME/etc/my_services/my_services_log.txt

solaar config k380 fn-swap False > /dev/null 2>&1 &

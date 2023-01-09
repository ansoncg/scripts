#!/bin/bash

lala=$(systemctl --user show-environment | grep LALA)
notify-send "VAR" "lala is $lala"

if [ -z "$lala" ]; then
    systemctl --user set-environment LALA=lele
else
    systemctl --user unset-environment LALA
fi

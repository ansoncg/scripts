#!/bin/bash

if [ $(xrandr --query | grep -c " connected") == "2" ] ; then
    $SCRIPTS_PATH/peripherals_config.sh -mn dual-single
else
    $SCRIPTS_PATH/peripherals_config.sh -mn single
fi

hsetroot -solid "#282a36"
$SCRIPTS_PATH/kb_auto_connect.sh

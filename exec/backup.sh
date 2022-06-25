#!/bin/bash

# Default compression alg => lz4
# Only for the path .../SONY/backup/borg

if [ "$1" == "-now" ] ; then
    borg create --progress /home/anderson/usb/anderson/SONY/backup/borg::backup-{now:%d-%m-%Y} \
        /home/anderson/files \
        /home/anderson/pictures \
        /home/anderson/etc \
        /home/anderson/compile_flags.txt 
elif [ "$1" == "-list" ] ; then
    borg list /home/anderson/usb/anderson/SONY/backup/borg
elif [ "$1" == "-check" ] ; then
    borg check /home/anderson/usb/anderson/SONY/backup/borg
else
    printf "Options:
    -now\tCreate a new backup with the current time
    -list\tList the backups
    -check\tCheck the backup consistency\n"
fi

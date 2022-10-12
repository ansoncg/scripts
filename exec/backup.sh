#!/bin/bash

# Default compression alg => lz4

BACKUP_PATH="$HOME/usb/anderson/SONY/backup/borg"

backup_now() {
    borg create --progress $BACKUP_PATH::backup-{now:%d-%m-%Y} \
        $HOME/files \
        $HOME/pictures \
        $HOME/music \
        $HOME/etc \
        $HOME/compile_flags.txt  \
        --exclude '*/node_modules/'
        
}

backup_list() {
    borg list $BACKUP_PATH
}

backup_check() {
    borg check $BACKUP_PATH
}

backup_info() {
    borg info $BACKUP_PATH
}

print_help() {
printf "\
Backup script
Options:
    -n, --now       Create a new backup with the current time
    -l, --list     List the backups
    -c, --check     Check the backup consistency
    -h, --help      Show this help\n"
}

case "$1" in
    -n|--now)
        backup_now ;;
    -l|--list)
        backup_list ;;
    -c|--check)
        backup_check ;;
    -i|--info)
        backup_info ;;
    -h|--help|*)
        print_help ;;
esac

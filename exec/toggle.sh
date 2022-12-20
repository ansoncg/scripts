#!/bin/bash

# ---

# TODO:
# - Intel gvt-g config

# ---

declare -A start
declare -A stop
declare -A explain

start[kdeconnect]=kdeconnect_start
start[vm]=vm_start
start[vcam]=vcam_start
start[wifi]=wifi_start
start[revtet]=revtet_start
start[debug]=debug_start

stop[kdeconnect]=kdeconnect_stop
stop[vm]=vm_stop
stop[vcam]=vcam_stop
stop[wifi]=wifi_stop
stop[revtet]=revtet_stop
stop[debug]=debug_stop

explain[kdeconnect]=kdeconnect_explain
explain[vm]=vm_explain
explain[vcam]=vcam_explain
explain[wifi]=wifi_explain
explain[revtet]=revtet_explain
explain[debug]=debug_explain

# ---

revtet_start() {
   gnirehtet run > /dev/null 2>&1 & disown 
}

revtet_stop() {
   killall gnirehtet
}

revtet_explain() {
   echo "Toggle reverse tethering for android"
}

# ---

kdeconnect_start() {
    /usr/lib/kdeconnectd > /dev/null 2>&1 & disown
    mpDris2 > /dev/null 2>&1 & disown
    # systemctl --user start app-org.kde.kdeconnect.daemon@autostart.service
    # systemctl --user start mpDris2.service
}

kdeconnect_stop() {
    killall kdeconnectd
    killall mpDris2
    # systemctl --user stop app-org.kde.kdeconnect.daemon@autostart.service
    # systemctl --user stop mpDris2.service
}

kdeconnect_explain() {
    printf "Control kdeconnect service and the mpDriss2 service, needed to interact with mpd.\n"
}

# ---

vm_start() {
    systemctl start libvirtd.service
    virt-manager
}

vm_stop() {
    echo "TODO" 
}

vm_explain() {
    printf "Control libvirtd service and virt-manager.\n"
}

# ---

vcam_start() {
    sudo modprobe v4l2loopback video_nr=3 card_label="My cam"
    pactl load-module module-pipe-source source_name=virtualmic file=/tmp/virtualmic format=s16le rate=44100 channels=1
}

vcam_stop() {
    sudo modprobe -r v4l2loopback
    pactl unload-module module-pipe-source
}

vcam_explain() {
    printf "Control v4l2loopback and virtualmic to create webcam emulation.\n"
}

# ---

wifi_start() {
    nmcli r wifi on
}

wifi_stop() {
    nmcli r wifi off
}

wifi_explain() {
    printf "Enable and disable wi-fi.\n"
}

# ---

debug_start() {
    echo "Debug message start"
}

debug_stop() {
    echo "Debug message stop"
}

debug_explain() {
    echo "Debug message explain"
}

# ---

get_registered_toggles() {
    toggles=""
    for key in "${!start[@]}"; do toggles+="${key} "; done
}

start_toggle() {
    ${start[$1]}
}

stop_toggle() {
    ${stop[$1]}
}

explain_toggle() {
    ${explain[$1]}
}

print_help() {
    get_registered_toggles
    printf "\
Manage the toggle of some applications, services and configurations
This script is to be used on stuff that you want to turn on and off

Options:
    -h, --help            Print this help

    Operations
        -s, --start <toggle>    Start task
        -x, --stop <toggle>     Stop task
        -e, --explain <toggle>  Explain task

Registerd toggles: %s\n" "$toggles"
}

print_error() {
    printf "Error: "
    case "$1" in
        args)
            printf "Invalid number of arguments -> '%s'\n" "$2" ;;
        operation)
            printf "Invalid operation -> '%s'\n" "$2" ;;
        toggle)
            printf "Invalid toggle -> '%s'\n" "$2" ;;
        empty)
            printf "No toggle specified -> '%s'\n" "$2" ;;
    esac
}

# ---

case $# in
    "0")
        print_help
        exit
        ;;
    "1")
        case "$1" in
            -h|--help)
                print_help ;;
            -s|--start| \
            -x|--stop| \
            -e|--explain)
                print_error empty "$1" ;;
            *)
                print_error operation "$1"
                exit
        esac
        ;;
    "2")
        case "$1" in
            -s|--start)
                operation=start_toggle ;;
            -x|--stop)
                operation=stop_toggle  ;;
            -e|--explain)
                operation=explain_toggle ;;
            *)
                print_error operation "$1"
                exit
        esac
        if [ -z ${start[$2]+_} ]; then 
            print_error toggle "$2"
            exit
        fi
        $operation "$2"
        ;;
    *)
        print_error args $#
        exit
        ;;
esac

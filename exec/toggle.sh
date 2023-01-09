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

command_line() {
	case $# in
	"0")
		print_help
		exit
		;;
	"1")
		case "$1" in
		-h | --help)
			print_help
            exit
			;;
        -s | --start)
			operation=start_toggle
            menu_name="Start Toggle"
			;;
        -x | --stop) 
			operation=stop_toggle
            menu_name="Stop Toggle"
            ;;
        -e | --explain)
			operation=explain_toggle
            menu_name="Explain Toggle"
            ;;
		*)
			print_error operation "$1"
			exit
			;;
		esac
        entry=$(fuzzy_list "$menu_name")
        if [ -z "$entry" ]; then 
            exit 
        fi
        $operation "$entry"
		;;
	"2")
		case "$1" in
		-s | --start)
			operation=start_toggle
			;;
		-x | --stop)
			operation=stop_toggle
			;;
		-e | --explain)
			operation=explain_toggle
			;;
		*)
			print_error operation "$1"
			exit
			;;
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
}

fuzzy_list() {
	get_registered_toggles
    toggles=$(echo "$toggles" | tr ' ' '\n')
    entry=$(
        fzf \
        --border=sharp \
        --header="$1" \
        --header-first \
        --cycle \
        --info=inline \
        --margin=0,0,0,0 \
        --padding=0,0,0,1 \
        --height=30%  \
        <<< "$toggles")
    echo "$entry"
}

print_help() {
	get_registered_toggles
	printf "\
Manage the toggle of some applications, services and configurations
This script is to be used on stuff that you want to turn on and off

Options:
    -h, --help            Print this help

    Operations
        -s, --start <toggle>    Start toggle
        -x, --stop <toggle>     Stop toggle
        -e, --explain <toggle>  Explain toggle

Registerd toggles: %s\n" "$toggles"
}

print_error() {
	printf "Error: "
	case "$1" in
	args)
		printf "Invalid number of arguments -> '%s'\n" "$2"
		;;
	operation)
		printf "Invalid operation -> '%s'\n" "$2"
		;;
	toggle)
		printf "Invalid toggle -> '%s'\n" "$2"
		;;
	empty)
		printf "No toggle specified -> '%s'\n" "$2"
		;;
	esac
}

process_start() {
	process_pid=$(pgrep --full "$1")
	if [ -z "$process_pid" ]; then
		$1 >/dev/null 2>&1 &
		disown
	else
		echo "Process '$1' is already running"
	fi
}

process_stop() {
	process_pid=$(pgrep --full "$1")
	if [ -z "$process_pid" ]; then
		echo "Process '$1' isn't running"
	else
		kill "$process_pid"
	fi
}

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

# Toggles -|-|-|-|-|-|-|-|-|-|-

# Reverse tethering ---

revtet_start() {
    process_start gnirehtet
}

revtet_stop() {
    process_stop gnirehtet
}

revtet_explain() {
	echo "Toggle reverse tethering for android with gnirehtet"
}

# KDE Connect ---

kdeconnect_start() {
	process_start /usr/lib/kdeconnectd
}

kdeconnect_stop() {
	process_stop /usr/lib/kdeconnect
}

kdeconnect_explain() {
	printf "Control kdeconnect service. mpDris2 is needed to interact with mpd.\n"
}

# Virt-manager ---

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

# Virtual cam ---

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

# Wi-Fi ---

wifi_start() {
	nmcli r wifi on
}

wifi_stop() {
	nmcli r wifi off
}

wifi_explain() {
	printf "Enable and disable wi-fi.\n"
}

# Debug toggle ---

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

command_line "$@"

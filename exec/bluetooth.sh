#!/bin/bash

# Register controllers
declare -A controllers
controllers[orico]=00:1A:7D:DA:71:13  # Bluetooth dongle
controllers[laptop]=D0:C5:D3:4C:92:20 # Internal laptop bluetooth

# Register devices
declare -A devices
devices[kb]=F4:73:35:5D:08:5E   # K380 keyboard
devices[jbl]=5C:FB:7C:0F:E3:B9  # JBL T450BT
devices[tws1]=5A:83:A2:99:2F:51 # TWS-6
devices[tws2]=5A:83:A2:99:2F:51 # TWS-6

# Register associations
declare -A associations
associations[kb]=orico
associations[jbl]=laptop
associations[tws1]=laptop
associations[tws2]=orico

list_connected() {
	# Get controllers to loop
	declare controllers
	controllers=$(printf "list" | bluetoothctl | grep "Controller" | cut -d ' ' -f 2)

	for controller in $controllers; do
		devices_connected=$(printf "select %s \n devices Connected" "$controller" | bluetoothctl | grep Device | cut -d ' ' -f 2)
		printf "Controller: %s \n" "$controller"
		for device in $devices_connected; do
			device_info=$(printf "select %s \n info %s" "$controller" "$device" | bluetoothctl)
			if echo "$device_info" | grep -q "Connected: yes"; then
				device_alias=$(echo "$device_info" | grep "Alias" | cut -d ' ' -f 2-)
				printf "Device: %s\n" "$device_alias"
			fi
		done
		printf "\n"
	done
}

get_registered_devices() {
	devs=""
	for key in "${!devices[@]}"; do devs+="${key} "; done
}

command_device() {
	if [ ${devices[$2]+_} ]; then
		controller=${controllers[${associations[$2]}]}
		printf "select %s\n$1 ${devices[$2]}\n" "$controller" | bluetoothctl
	else
		get_registered_devices
		printf "Device '$2' not found\nRegistered devices: %s\n" "$devs"
	fi
}

reconnect_device() {
	command_device disconnect "$1"
	sleep 10
	command_device connect "$1"
}

print_help() {
	get_registered_devices
	printf "\
Bluetooth script
Options:
     -c, --connect     Connect a device
     -d, --disconnect  Disconnect a device
     -r, --reconnect   Disconnect a device and reconnect after 10 seconds
     -i, --info        Get info about a device
     -l, --list        List connected devices
     Registered devices: %s\n" "$devs"
}

if [ "$(systemctl is-active "bluetooth.service")" = "inactive" ]; then
	printf "Bluetooth is off\n"
else
	case "$1" in
	-c | --connect)
		command_device connect "$2"
		;;
	-d | --disconnect)
		command_device disconnect "$2"
		;;
	-r | --reconnect)
		reconnect_device "$2"
		;;
	-i | --info)
		command_device info "$2"
		;;
	-l | --list)
		list_connected
		;;
	-h | --help | *)
		print_help
		;;
	esac
fi

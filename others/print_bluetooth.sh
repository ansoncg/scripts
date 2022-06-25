#!/bin/sh

print_bluetooth() {
    if [ "$(systemctl is-active "bluetooth.service")" = "active" ]; then

        # get controllers to loop
        controllers=$(printf "list" | bluetoothctl | grep anderson-pc | cut -d ' ' -f 2)
        counter=0

        for controller in $controllers; do
            devices_paired=$(printf "select $controller \n paired-devices" | bluetoothctl | grep Device | cut -d ' ' -f 2)
            for device in $devices_paired; do
                device_info=$(printf "select $controller \n info $device" | bluetoothctl)
                if echo "$device_info" | grep -q "Connected: yes"; then
                    device_alias=$(echo "$device_info" | grep "Alias" | cut -d ' ' -f 2-)

                    if [ $counter -gt 0 ]; then
                        printf ", %s" "$device_alias"
                    else
                        printf " %s" "$device_alias"
                    fi
                    counter=$((counter + 1))
                fi
            done
        done

        printf ' \n'
    else
        echo " Off"
    fi

}

case "$1" in
    *)
        print_bluetooth
        ;;
esac

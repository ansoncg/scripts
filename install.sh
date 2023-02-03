#!/bin/bash

# sudo find "$SCRIPTS_PATH" -type f -exec ln {} . \;

craete_dirs() {
	true
}

arch_hooks() {
	true
}

install_packages() {
    skip_headers=1
	while IFS=, read -r package install manager _ ; do
        if ((skip_headers)); then 
            ((skip_headers--)) 
            continue
        fi
        if [ "$install" == yes ] && { [ "$manager" == pacman ] || [ "$manager" == aur ]; }; then
            echo "$package"
        fi
	done < /home/anderson/etc/packages.csv
}

enable_services() {
	true
}

install_archlinux() {
	install_packages
	enable_services
}

install_packages

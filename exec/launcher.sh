#!/bin/bash

# Dependencies:
# - fzf
# - bat
# - gtk-launch

cache_path=$HOME/etc/my_apps_data
log_path="$HOME"/etc/my_apps_data/launcher.log
apps_path=/usr/share/applications

update_cache() {
    mkdir -p "$cache_path"
    cd "$cache_path" || exit 1
    true > launcher.cache # clear file
    files=$(ls $apps_path)
    for file in $files; do
        ini=$(sed -e '/^$/,$d' $apps_path/"$file") # File up to first empty line
        name=$(echo "$ini" | grep "^Name=" | cut -d '=' -f2-) # Name=
        if [ "$name" ] ; then
            printf "%s : %s\n" "$name" "$file" >> launcher.cache
        fi
    done
    sort -u -t: -k1,1 launcher.cache -o launcher.cache # Unique sort by name
    printf "Launcher cache updated.\n"
}

run_launcher() {
    entry=$(
        fzf \
        --border=sharp \
        --header="Software launcher" \
        --header-first \
        --cycle --info=inline \
        --margin=0,0,0,0 \
        --padding=0,0,0,1 \
        --height=50%  \
        --multi \
        < "$cache_path"/launcher.cache)
    app_name=$(echo "$entry" | cut -d ':' -f 1)
    desktop_file=$(echo "$entry" | cut -d ':' -f 2)
    if [ "$app_name" ]; then
        printf "Running: %s\n" "$app_name"
        printf "%s\n" "gtk-launch ${desktop_file:1} >> $log_path 2>&1"
        gtk-launch "${desktop_file:1}" >> "$log_path" 2>&1
    fi
}

show_help() {
        printf "\
Software launcher
Options:
    -u, --update    Update cache
    -c, --cache     Show cache
    -h, --help      Show this help
"
}

case "$1" in
    -u|--update)
        update_cache
        ;;
    -c|--cache)
        bat "$cache_path"/launcher.cache
        ;;
    -h|--help)
        show_help
        ;;
    *)
        run_launcher
        ;;
esac

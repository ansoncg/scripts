#!/bin/bash

# Dependencies:
# - fzf
# - bat

cache_path=$HOME/etc/my_apps_data
apps_path=/usr/share/applications

update_cache() {
    mkdir -p "$cache_path"
    cd "$cache_path" || exit 1
    true > launcher.cache # clear file
    files=$(ls $apps_path)
    for file in $files; do
        ini=$(sed -e '/^$/,$d' $apps_path/"$file") # File up to first empty line
        name=$(echo "$ini" | grep "^Name=" | cut -d '=' -f2-) # Name=
        exe=$(echo "$ini" | grep "^Exec=" | cut -d '=' -f2- | cut -d '%' -f 1) # Exec=
        if [ "$name" ] && [ "$exe" ]; then # If both exist
            printf "%s : %s\n" "$name" "$exe" >> launcher.cache
        fi
    done
    sort -u launcher.cache -o launcher.cache
    printf "Launcher cache updated.\n"
}

run_app() {
    entry=$(
        fzf \
        --border=sharp \
        --header="Software launcher" \
        --header-first \
        --cycle --info=inline \
        --margin=0,49%,0,0 \
        --padding=0,0,0,1 \
        --height=50%  \
        --multi \
        < "$cache_path"/launcher.cache)
    exe=$(echo "$entry" | cut -d ':' -f 2)
    printf "Running:%s\n" "$exe"
    $exe >> "$HOME"/etc/my_apps_data/launcher.log 2>&1 & disown
}

show_help() {
        printf "\
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
        run_app
        ;;
esac

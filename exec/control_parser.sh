#!/bin/bash

# Dependencies
# - fzf
# - json parser with jq syntax

# CONFIG ----
parser=
bin_path=
menus_path=

config_path="/home/anderson/etc/my_apps_data/menu.conf"
eval "$(cat "$config_path")"

# -----------

# VARIABLES -----------
index=0
cols=$(tput cols) # Terminal cols
space=$(((cols / 2) - 15))

declare -A run
declare -A type
declare -A is_redirected

# -----------

print_help() {
	printf "\
Control menu
Options:
    -h, --help      Show this help
    -r, --reopen    Open last used menu file
    -l, --list      List the menu json files
    -s, --string    Input is a json string, not a file 
"
}

parse_command_line() {
	case $# in
	"0")
		menu_json=$(cat "$menus_path"/root.json)
        ln -sf "$menus_path"/root.json /tmp/menu_last
		;;
	"1")
		case "$1" in
		-h | --help)
			print_help
			exit 0
			;;
        -r | --reopen) # Open last used menu file
            if [ -f /tmp/menu_last ]; then
                menu_json=$(cat /tmp/menu_last)
            else
                menu_json=$(cat "$menus_path"/root.json)
            fi
            ;;
        -l | --list)
            ls "$menus_path"
            exit 0
            ;;
		*)
			menu_json=$(cat "$menus_path"/"$1".json)
            ln -sf "$menus_path"/"$1".json /tmp/menu_last
			;;
		esac
		;;
	"2")
		case "$1" in
		-s | --string)
			menu_json="$2" # Input is a string
			;;
		esac
		;;
	esac
}

truncate_string() {
	string=$1
	((${#string} > space)) && string="${string:0:space-1}~"
	echo "$string"
}

json_parse_show() {
	while read -r start_end; do

		command_len=$start_end
		for _ in $(seq 1 "$command_len"); do
			index=$((index + 1)) # Counter

			# Read 'command' attributes from json
			read -r label
			read -r execute
			read -r help

			type["$index"]="command" # Set the option type
			run["$index"]=$execute   # Set the command to run

            if [ -z "$help" ]; then
                help="$menus_path/placeholder.md"
            fi

			# Truncate fields
			label=$(truncate_string "$label")
			execute=$(truncate_string "$execute")

			# Add line to print to the result
			printf -v temp_string "| %s | %-7s | %-${space}s | %-${space}s | %s \n" \
				"$index" "Command" "$label" "$execute" "$help"
			result+=$temp_string
		done

		read -r file_len
		for _ in $(seq 1 "$file_len"); do
			index=$((index + 1))

			# Read 'file' attributes from json
			read -r label
			read -r path
			file=$(basename "$path") # Only filename

			type["$index"]="file"         # Set the option type
			run["$index"]="$EDITOR $path" # Set the command to run

			# Truncate fields
			label=$(truncate_string "$label")
			file=$(truncate_string "$file")

			# Add line to print to the result
			printf -v temp_string "| %s | %-7s | %-${space}s | %-${space}s | %s \n" \
				"$index" "File" "$label" "$file" "$path"
			result+=$temp_string
		done

		read -r menu_len
		for _ in $(seq 1 "$menu_len"); do
			index=$((index + 1))

			# Read 'menu' attributes from json
			read -r label
			read -r direction
			read -r json

			# Set the option type
			type["$index"]="menu"

			# Truncate fields
			label=$(truncate_string "$label")

			# Set the command to run. See if there's a redirection
			if [ "$direction" == null ] || [ -z "$direction" ]; then
				is_redirected["$index"]=false
				run["$index"]="$json"
				direction="placeholder.md"
			else
				is_redirected["$index"]=true
				run["$index"]="$direction"
			fi

			# Add line to print to the result
			printf -v temp_string "| %s | %-7s | %-${space}s | %-${space}s | %s \n" \
				"$index" "Menu" "$label" "" "$menus_path/$direction.json"
			result+=$temp_string
		done

		# Parse JSON
	done < <($parser -rc \
		'(.command | length , (.[] | .label, .execute, .help))
        ,(.file | length , (.[] | .label, .path)) 
        ,(.menu | length , (.[] | .label, .direction, .))' \
		<<<"$menu_json")
}

pick_option() {
	entry=$(
		echo -e "${result::-1}" | fzf \
			--delimiter='\|' \
			--with-nth=..-2 \
			--preview="cat {-1}" \
			--preview-window up \
			--preview-window 60% \
			--preview-window border-sharp \
			--preview-window wrap \
			--cycle --info=inline \
			--border=sharp \
			--header="Control menu" \
			--header-first \
			--margin=0,0,0,0 \
			--padding=0,0,0,1 \
			--tac
	)
	choice=$(echo "$entry" | cut -d ' ' -f2)
}

execute_option() {
	if [ "$choice" ]; then
		case "${type["$choice"]}" in
		"command")
			exec bash -c "${run[$choice]}"
			;;
		"file")
			${run[$choice]}
			;;
		"menu")
			if [ "${is_redirected["$choice"]}" == true ]; then
				exec "$bin_path"/control_parser.sh "${run["$choice"]}"
			else
				exec "$bin_path"/control_parser.sh --string "${run["$choice"]}"
			fi
			;;
		*) ;;
		esac
	fi
}

main() {
	parse_command_line "$@"
	json_parse_show
	pick_option
	execute_option
}

main "$@"
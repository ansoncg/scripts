#!/bin/bash

# Dependencies
# - fzf
# - json parser with jq syntax

# CONFIG ----
parser=jaq
bin_path=$SCRIPTS_PATH
menus_path="/home/anderson/etc/my_apps_data/control_menu"

# Or a config file
# config_path="/home/anderson/etc/my_apps_data/menu.conf"
# eval "$(cat "$config_path")"

# -----------

# VARIABLES -----------
index=0
cols=$(tput cols) # Terminal cols
space=$(((cols / 2) - 15))

declare -A run
declare -A opt_type
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

        # COMMAND
		command_len=$start_end
		for _ in $(seq 1 "$command_len"); do
			index=$((index + 1)) # Counter

			# Read 'command' attributes from json
			read -r label
			read -r execute
			read -r help # Can be a file or a string

			opt_type["$index"]="command" # Set the option type
			run["$index"]=$execute       # Set the command to run

			# Show this if there's no help set
			if [ -z "$help" ]; then
				help="Nothing to show"
			fi

			# Truncate fields
			label=$(truncate_string "$label")
			execute=$(truncate_string "$execute")

			# Add line to print to the result
			printf -v temp_string "| %s | %-7s | %-${space}s | %-${space}s | %s \n" \
				"$index" "Command" "$label" "$execute" "$help"
			result+=$temp_string
		done

        # TEXT
		read -r text_len
		for _ in $(seq 1 "$text_len"); do
			index=$((index + 1))

			# Read 'text' attributes from json
			read -r label
			read -r content

            if [ -f "$content" ]; then
                info="file: $(basename "$content")" # Only filename. The content is a file.
                run["$index"]="$EDITOR $content" # Set the command to run
            else
                info="string: $content" # The content is a string
                run["$index"]="echo $content" # Set the command to run
            fi
			opt_type["$index"]="text"     # Set the option type

			# Truncate fields
			label=$(truncate_string "$label")
			info=$(truncate_string "$info")

			# Add line to print to the result
			printf -v temp_string "| %s | %-7s | %-${space}s | %-${space}s | %s \n" \
				"$index" "Text" "$label" "$info" "$content"
			result+=$temp_string
		done

        # MENU
		read -r menu_len
		for _ in $(seq 1 "$menu_len"); do
			index=$((index + 1))

			# Read 'menu' attributes from json
			read -r label
			read -r direction
			read -r json

			# Set the option opt_type
			opt_type["$index"]="menu"

			# Truncate fields
			label=$(truncate_string "$label")

			# Set the command to run. See if there's a redirection
			if [ "$direction" == null ] || [ -z "$direction" ]; then
				is_redirected["$index"]=false
				run["$index"]="$json"
				direction="empty"
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
        ,(.text | length , (.[] | .label, .content)) 
        ,(.menu | length , (.[] | .label, .direction, .))' \
		<<<"$menu_json")
}

pick_option() {
	entry=$(
		echo -e "${result::-1}" | fzf \
			--delimiter='\|' \
			--with-nth=..-2 \
			--preview=" if [ -f {-1} ]; then
                            cat {-1}
                        else 
                            echo {-1}
                        fi " \
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
		case "${opt_type["$choice"]}" in
		"command")
			exec bash -c "${run[$choice]}"
			;;
		"text")
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

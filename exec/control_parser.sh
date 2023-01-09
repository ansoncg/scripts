#!/bin/bash

# Dependencies -|-|-|-
# - fzf
# - json parser with jq syntax

# Optional
# - Search: ripgrep
# - Graph: graphviz

# -----------

# CONFIG -|-|-|-
parser=jaq
bin_path=$SCRIPTS_PATH
data_path="/home/anderson/etc/my_apps_data/"
menus_path="/home/anderson/etc/my_apps_data/control_menu"

# Or a config file
# config_path="/home/anderson/etc/my_apps_data/menu.conf"
# eval "$(cat "$config_path")"

# -----------

# VARIABLES -|-|-|-
index=0
cols=$(tput cols) # Terminal cols
space=$(((cols / 2) - 15))
delim="+@!#" # Something hard to appear in a file

declare -A run
declare -A opt_type
declare -A is_redirected

# -----------

parse_command_line() {
	case $# in
	"0")
		if [ -f "$menus_path"/root.json ]; then
			menu_json=$(cat "$menus_path"/root.json)
			ln -sf "$menus_path"/root.json /tmp/menu_last
		else
			error 2
		fi
		execute_menu
		;;
	"1")
		case "$1" in
		-h | --help)
			print_help
			;;
		-r | --reopen) # Open last used menu file
			if [ -f /tmp/menu_last ]; then
				menu_json=$(cat /tmp/menu_last)
			else
				menu_json=$(cat "$menus_path"/root.json)
			fi
			execute_menu
			;;
		-g | --graph)
			debugging_graph
			;;
		-l | --list)
			list_menus
			;;
		*)
			if [ -f "$menus_path"/"$1".json ]; then
				menu_json=$(cat "$menus_path"/"$1".json)
				ln -sf "$menus_path"/"$1".json /tmp/menu_last
			else
				error 3 "$1"
			fi
			execute_menu
			;;
		esac
		;;
	"2")
		case "$1" in
		-p | --parse)
			menu_json=$(cat "$menus_path"/"$2".json)
			menu_preview
			;;
		-s | --search)
			grep_search "$2"
			;;
		--recursive)
			menu_json="$2" # Input is a string
			execute_menu
			;;
		--recursiveparse)
			menu_json="$2" # Input is a string
			menu_preview
			;;
		*)
			error 1
			;;
		esac
		;;
	*)
		error 1
		;;
	esac
}

print_help() {
	printf "\
Control menu
Options:
    -h, --help          Show this help.
    -r, --reopen        Open last used menu file.
    -l, --list          List the menu json files.
    -p, --parse         Only parse and show the menu file.
    -s, --search        Grep search all menu files and content they point to.
    -g, --graph         Draw a graph of the menus json files for a visual help.
    --recursive         Process a submenu inside a menu. Internal use.
    --recursiveparse    The 'recursive' and 'parse' options together. Internal use.
"
	exit 0
}

error() {
	case "$1" in
	1)
		echo "Wrong arguments"
		;;
	2)
		echo "No root file found"
		;;
	3)
		echo "No '$2.json' found at '$menus_path'"
		;;
	esac
	exit "$1"
}

truncate_string() {
	string=$1
	((${#string} > space)) && string="${string:0:space-1}~"
	echo "$string"
}

menu_preview() {
	space=$((space + 3))
	json_parse_show
	echo -e "${result::-1}" | awk -F $delim '{print $1}'
	exit 0
}

json_parse_show() {
	while read -r start_end; do

		# COMMAND
		title=$start_end
		read -r command_len
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

			# Add line to print to the result. Eveything after the first delim is not shown.
			printf -v temp_string "| %02d | %-7s | %-${space}s | %-${space}s | $delim%s$delim%s$delim%s\n" \
				"$index" "Command" "$label" "$execute" "$index" "Command" "$help"
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
				info="$(basename "$content")"    # Only the file name. The content is a file.
				run["$index"]="$EDITOR $content" # Set the command to run
			else
				info="$content"               # The content is a string
				run["$index"]="echo $content" # Set the command to run
			fi
			opt_type["$index"]="text" # Set the option type

			# Truncate fields
			label=$(truncate_string "$label")
			info=$(truncate_string "$info")

			# Add line to print to the result. Eveything after the first delim is not shown.
			printf -v temp_string "| %02d | %-7s | %-${space}s | %-${space}s | $delim%s$delim%s$delim%s\n" \
				"$index" "Text" "$label" "$info" "$index" "Text" "$content"
			result+=$temp_string
		done

		# MENU
		read -r menu_len
		for _ in $(seq 1 "$menu_len"); do
			index=$((index + 1))

			# Read 'menu' attributes from json
			read -r label
			read -r direction
			read -r level
			read -r json

			# Set the option opt_type
			opt_type["$index"]="menu"

			# Truncate fields
			label=$(truncate_string "$label")

			# Set the command to run. See if there's a redirection
			if [ "$direction" == null ] || [ -z "$direction" ]; then
				is_redirected["$index"]=false
				run["$index"]="$json"
				direction="$json"
			else
				is_redirected["$index"]=true
				run["$index"]="$direction"
			fi

			# Add line to print to the result. Eveything after the first delim is not shown.
			printf -v temp_string "| %02d | %-7s | %-${space}s | %-${space}s | $delim%s$delim%s$delim%s\n" \
				"$index" "Menu" "$label" "$level" "$index" "Menu" "$direction"
			result+=$temp_string
		done

		# Parse JSON
	done < <($parser -rc \
		'(.label)
		,(.command | length , (.[] | .label, .execute, .help))
        ,(.text | length , (.[] | .label, .content)) 
        ,(.menu | length , (.[] | .label, .direction, .level, .))' \
		<<<"$menu_json")
}

pick_option() {
	entry=$(
		echo -e "${result::-1}" | fzf \
			--delimiter=$delim \
			--with-nth=1 \
			--no-hscroll \
			--preview-window up \
			--preview-window 60% \
			--preview-window border-sharp \
			--preview-window wrap \
			--cycle \
			--info=inline \
			--border=sharp \
			--header="Control menu - $title" \
			--header-first \
			--margin=0,0,0,0 \
			--padding=0,0,0,1 \
			--ellipsis="" \
			--tac \
			--preview=" if [ {-2} == Menu ]; then
                            if [ -f \"$menus_path\"/{-1}.json ]; then
                                \"$bin_path\"/control_parser.sh --parse {-1}
                            else
                                \"$bin_path\"/control_parser.sh --recursiveparse {-1}
                            fi
                        elif [ -f {-1} ]; then
                            cat {-1}
                        else 
                            echo {-1}
                        fi "
	)
	if [ "$entry" ]; then
		choice=$(echo "$entry" | awk -F $delim '{print $(NF-2)}')
	fi
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
				exec "$bin_path"/control_parser.sh --recursive "${run["$choice"]}"
			fi
			;;
		*) ;;
		esac
	fi
}

execute_menu() {
	json_parse_show
	pick_option
	execute_option
}

list_menus() {
	ls "$menus_path"
	exit 0
}

grep_search() {
	files=$(ls $menus_path)
	file_list=""

	for file in $files; do
		menu_json=$(cat "$menus_path/$file")
		file_list+="$menus_path/$file\n"
		while read -r text_len; do
			for _ in $(seq 1 "$text_len"); do
				read -r content
				if [ -f "$content" ]; then
					file_list+="$content\n"
				fi
			done
		done < <($parser -rc \
			'(.text | length , (.[] | .content))' \
			<<<"$menu_json")
	done
	file_list=$(echo -e "$file_list" | sort -u)
	rg --column --line-number --color=always --smart-case --context 1 "$1" $file_list
	exit 0
}

debugging_graph() {
	graph_string_ini="digraph G { rankdir=LR; center=true; concentrate=true; ranksep=2; nodesep=1 "
	graph_string_mid=""

	files=$(ls $menus_path)
	files=${files/root.json/}
	files=${files/template.json/}
	files=${files/all.json/root.json} # GAMBI (TODO)

	for file in $files; do
		menu_json=$(cat "$menus_path/$file")

		while read -r menu_len; do
			read -r direction
			read -r level

			file=$(echo "$file" | cut -d '.' -f1)
			graph_string_mid+="$file [shape=box]; \n"
			if [ "$direction" != "" ]; then
				# graph_string_mid+="$file -> $direction [label=$level]; \n"
				graph_string_mid+="$file -> $direction ; \n"
			fi
		done < <($parser -rc \
			'(.menu | length , (.[] | .direction, .level, .))' \
			<<<"$menu_json")

	done
	graph_string+="$graph_string_ini$graph_string_mid }"
	echo -e "$graph_string" | dot -T png >"$data_path"/menu_graph.png
}

parse_command_line "$@"

#!/bin/bash

killall inotifywait

# Recursive
inotifywait \
	-e close_write \
	-e create \
	-e delete \
	-e move \
	--format "%T | %w%f | %e%n" \
	--no-newline \
	--timefmt "%c" \
	-Prm \
	~/.config \
	--exclude \
	"fish_history|ranger/bookmarks|ranger/history|mpd" \
	-o /home/anderson/etc/my_apps_data/state.log &

# Non Recursive
inotifywait \
	-e close_write \
	-e create \
	-e delete \
	-e move \
	--format "%T | %w%f | %e%n" \
	--no-newline \
	--timefmt "%c" \
	-Pm \
	/home/anderson \
	~/.local/share \
	--exclude \
	"bash_history" \
	-o /home/anderson/etc/my_apps_data/state.log &

# 	|
# 	while IFS= read -r -d '' message; do
# 		echo "$message"
# 	done &

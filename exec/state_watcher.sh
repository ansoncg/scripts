#!/bin/bash

killall inotifywait

# Video thumbnails
"$SCRIPTS_PATH"/thumbnail_handler.sh --notify

# Recursive. ~/.config
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

# Non Recursive. ~, ~/.local/share
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
	"bash_history|python_history" \
	-o /home/anderson/etc/my_apps_data/state.log &

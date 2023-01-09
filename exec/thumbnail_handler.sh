#!/bin/bash

# Dependencies
# - mpv
# - vimiv
# - ffmpegthumbnailer

thumbnails_path="/home/anderson/videos/thumbnails"
videos_path="/home/anderson/videos"

parse_command_line() {
	case $1 in
	-c | --create)
		create_directories
		create_thumbnails
		;;
	-o | --open)
		open_video_thumbnails
		;;
	-r | --run)
		run_video_from_thumbnail "$2"
		;;
	esac
}

open_video_thumbnails() {
	find "$thumbnails_path" -type f -printf "\"%p\"\n" | xargs vimiv --command "enter thumbnail" \
		--command "set statusbar.show True" \
        --command 'bind v "!/home/anderson/files/scripts/exec/thumbnail_handler.sh --run \%"'
}

run_video_from_thumbnail() {
	path="$videos_path"/$(echo "$1" | awk -F "thumbnails/" '{print $2}')
	mpv "${path%.*}"
}

create_directories() {
	cd $videos_path || exit
	while read -r entry; do
		mkdir -p "$thumbnails_path"/"$entry"
	done < <(find . -type d)
}

create_thumbnails() {
	cd $videos_path || exit
	while read -r entry; do
		ext="${entry##*.}"
		case "$ext" in
		"mp4" | "webm" | "mkv")
			echo "$entry"
			ffmpegthumbnailer -i "$entry" -o "$thumbnails_path"/"$entry".png -s 512
			;;
		esac
	done < <(find .)
}

parse_command_line "$@"

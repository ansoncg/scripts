#!/bin/bash

auth=$(head -1 "$HOME"/etc/my_apps_data/twitch.keys)
id=$(tail -1 "$HOME"/etc/my_apps_data/twitch.keys)

cols=$(tput cols)
name_len=20
game_len=25
viewers_len=7
right_pad=10
title_len=$((cols - name_len - game_len - viewers_len - right_pad))

print_following_data() {
	# My channel request (Bucaco id=52363379)
	response=$(
		curl -s "https://api.twitch.tv/helix/streams/followed?user_id=52363379" \
			-H "Authorization: Bearer $auth" \
			-H "Client-ID: $id"
	)

	# Read line by line of the parsed json
	while read -r name; do
		read -r game
		read -r title
		read -r viewers

		# Truncate strings
		((${#name} > name_len)) && name="${name:0:name_len-1}~"
		((${#game} > game_len)) && game="${game:0:game_len-1}~"
		((${#title} > title_len)) && title="${title:0:title_len-1}~"

		# Print left aligned
		printf "%-${name_len}s %-${game_len}s %-${viewers_len}s %-${title_len}s\n" \
			"$name" "$game" "$viewers" "$title"

		# Parse json with jq
	done < <(echo "$response" | jq -r '.data[] | (.user_name, .game_name, .title, .viewer_count)')
}

print_moon_title() {
    moon_response=$(
        curl -s "https://api.twitch.tv/helix/channels?broadcaster_id=121059319" \
            -H "Authorization: Bearer $auth" \
            -H "Client-ID: $id"
    )
    moon_title=$(echo "$moon_response" | jq -r '.data[].title')
    printf "\nMoonmoon title: %s\n" "$moon_title"
}

print_following_data
print_moon_title

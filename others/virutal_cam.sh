#!/bin/bash

pactl load-module module-pipe-source source_name=virtualmic file=/tmp/virtualmic format=s16le rate=44100 channels=1
sudo modprobe v4l2loopback video_nr=3 card_label="My cam"
v4l2-ctl --list-devices

Arquivo com som:
ffmpeg -stream_loop 3000 -re -i input.mp4 -map 0:v -f v4l2 /dev/video3 -f s16le -ar 44100 -ac 1 - > /tmp/virtualmic

Stream com som:
streamlink --stdout https://www.twitch.tv/esl_csgo best | ffmpeg -stream_loop 3000 -re -i pipe:0 -map 0:v -f v4l2 /dev/video3 -f s16le -ar 44100 -ac 1 - > /tmp/virtualmic

Video com som yt-dlp:
yt-dlp "https://www.youtube.com/watch?v=JcXjbY7IX7I" -o - | ffmpeg -stream_loop 3000 -re -i pipe:0 -map 0:v -f v4l2 /dev/video3 -f s16le -ar 44100 -ac 1 - > /tmp/virtualmic


# Remove audio
pactl unload-module module-pipe-source

# Remove cam
sudo modprobe -r v4l2loopback

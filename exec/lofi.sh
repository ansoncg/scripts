#!/bin/bash

manifest=$(yt-dlp -g "https://www.youtube.com/watch?v=5qap5aO4i9A")
mpc insert $manifest
mpc next
mpc play

# mpv --no-video "https://www.youtube.com/watch?v=DWcJFNfaw9c"

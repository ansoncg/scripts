#!/bin/bash

manifest=$(yt-dlp -g "https://www.youtube.com/watch?v=jfKfPfyJRdk")
mpc insert $manifest
mpc next
mpc play


# mpv --no-video "https://www.youtube.com/watch?v=DWcJFNfaw9c"

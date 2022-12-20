#!/bin/bash

manifest=$(yt-dlp -g "https://www.youtube.com/watch?v=jfKfPfyJRdk")
mpc insert "$manifest"
mpc play
mpc next
mpc play

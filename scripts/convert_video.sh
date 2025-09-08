#!/bin/bash

directory='/Users/juliamainzinger/Documents/Projects/mvskoke_code/mvskoke_hymnal/extras/recordings'

for file in "$directory"/*.mp4; do
    [ -e "$file" ] || continue
    base="${file%.mp4}"
    ffmpeg -i "$file" -q:a 0 -map a "${base}.mp3"
done
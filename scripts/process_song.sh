#!/bin/bash
source /Users/juliamainzinger/miniconda3/bin/activate base

# first argument is the file to process
# check if the file exists
if [ ! -f "$1" ]; then
    echo "File not found!"
    exit 1
fi

filename="$1"

# split lyrics and add to database
python split_lyrics.py "$filename"
en_filename="${filename%.*}_en.chordpro"
python add_to_csv.py "$en_filename" ../extras/songbook/songs.tsv
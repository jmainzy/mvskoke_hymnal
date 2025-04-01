#!/bin/bash
source /Users/juliamainzinger/miniconda3/bin/activate base

# Directory containing the files
INPUT_DIR="../extras/output"
OUTPUT_DIR="../extras/processed"

Loop through all files in the directory
for file in "$INPUT_DIR"/*; do
    # read raw text file
    python process_song.py "$file" "$OUTPUT_DIR"
done

for file in "$OUTPUT_DIR"/*; do
    # skip files ending in _en.chordpro
    if [[ "$file" == *_en.chordpro ]]; then
        continue
    fi
    # skip files ending in _mus.chordpro
    if [[ "$file" == *_mus.chordpro ]]; then
        continue
    fi
    # read raw text file
    python split_lyrics.py "$file"
done

# recreate songs.tsv file
tsv_file="../extras/songbook/songs.tsv"
rm "$tsv_file"
touch "$tsv_file"
# add header to songs.tsv
cat "id	title	title_en	lyrics_en	lyrics	tags	pages" > "$tsv_file"

# loop through files ending in _en.chordpro
for file in "$OUTPUT_DIR/"*_en.chordpro; do
    if [ ! -e "$file" ]; then continue; fi
    # read raw text file
    python add_to_csv.py "$file" "$tsv_file"
done
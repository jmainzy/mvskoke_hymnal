#!/bin/bash

# Change to the directory containing the files
dirname="$1"

for file in "$dirname"/*\ *; do
    echo "Renaming '$file'..."
    newname=$(echo "$file" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    mv "$file" "$newname"
done
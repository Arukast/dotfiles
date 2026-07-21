#!/bin/bash
for file in "$@"; do
    if [ -f "$file" ]; then
        filename="${file%.*}"
        cwebp -q 80 "$file" -o "${filename}.webp"
    fi
done

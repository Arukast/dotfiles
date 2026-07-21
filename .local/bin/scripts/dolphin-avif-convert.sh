#!/bin/bash
for file in "$@"; do
    if [ -f "$file" ]; then
        filename="${file%.*}"
        # --jobs default utilizes multiple cores; speed 6 is a good balance
        /usr/bin/avifenc --jobs default --speed 6 "$file" "${filename}.avif"
    fi
done

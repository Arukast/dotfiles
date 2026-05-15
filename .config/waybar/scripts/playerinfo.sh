#!/usr/bin/env bash

# Get metadata using playerctl
# We get artist, title, and playerName in one go
metadata=$(playerctl metadata --format '{{artist}}||{{title}}||{{playerName}}' 2>/dev/null)

if [[ -z "$metadata" ]]; then
    exit 1
fi

# Split metadata
IFS='||' read -r artist title player <<< "$metadata"

# Combine artist and title
full_text="$artist - $title"
maxlength=35

# Truncate if necessary
if [ ${#full_text} -gt $maxlength ]; then
    display_text="${full_text:0:$((maxlength-3))}..."
else
    display_text="$full_text"
fi

# Output JSON
printf '{"text": "%s", "tooltip": "%s: %s"}\n' "$display_text" "$player" "$full_text"
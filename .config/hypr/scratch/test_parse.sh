#!/bin/bash

CONFIG_FILE="/home/arukast/.config/hypr/custom/keybinds.conf"

list=$(awk '
    BEGIN { section = "General" }
    /^##!/ { section = substr($0, 5); next }
    /^(bind|binde|bindl|bindm|bindd|bindel|bindld)/ {
        line = $0
        
        # Extract mods and key (always first two parts)
        # First remove the command and equals sign
        content = line
        sub(/^[a-z]+ *= */, "", content)
        split(content, parts, ",")
        
        mods = parts[1]; gsub(/ /, "", mods)
        key = parts[2]; gsub(/ /, "", key)
        
        # Description extraction
        desc = ""
        if (line ~ /^bindd/) {
            desc = parts[3]
            gsub(/^ */, "", desc); gsub(/ *$/, "", desc)
        } else if (line ~ /#/) {
            split(line, comment, "#")
            desc = comment[2]
            gsub(/^ */, "", desc); gsub(/ *$/, "", desc)
        }

        if (desc ~ /\[hidden\]/) next
        if (desc == "") next

        # Clean up mods display
        gsub(/\$mainMod/, "SUPER", mods)
        
        printf "%-15s | %-25s | %s\n", section, mods "+" key, desc
    }
' "$CONFIG_FILE")

echo "$list"

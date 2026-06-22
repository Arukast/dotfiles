#!/bin/bash

# Give the desktop environment a few seconds to initialize
sleep 5

# Function to check if any AC power supply is online
is_on_ac() {
    for supply in /sys/class/power_supply/AC*/online; do
        if [ -f "$supply" ]; then
            if [ "$(cat "$supply")" -eq 1 ]; then
                return 0
            fi
        fi
    done
    return 1
}

if is_on_ac; then
    echo "Running on AC power. Starting applications..."
    
    # Launch Steam in the background/tray
    steam -silent &
    
    # Launch Discord
    discord --start-minimized &
    
    # Launch Spotify
    "$HOME/.local/bin/spotify-patched" &
else
    echo "Running on battery. Skipping autostart applications."
fi

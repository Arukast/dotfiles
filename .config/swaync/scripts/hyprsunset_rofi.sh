#!/bin/bash

# Configuration
TEMP_MANUAL=5000
TEMP_EXTRA=3500
STATE_FILE="/tmp/hyprsunset_mode"

# Rofi Menu Styling (Compact & centered)
options="🕒 Auto\n🌙 Manual ($TEMP_MANUAL K)\n🔥 Extra Warm ($TEMP_EXTRA K)\n☀️ Off"

selected=$(echo -e "$options" | rofi -dmenu -p "Night Light" -theme-str 'window {width: 15%;} listview {lines: 4;}')

[[ -z "$selected" ]] && exit 0

# Kill existing instance
pkill -x hyprsunset

case "$selected" in
    *"Auto"*)
        hyprsunset > /dev/null 2>&1 & disown
        echo "auto" > "$STATE_FILE"
        ;;
    *"Manual"*)
        hyprsunset --temperature $TEMP_MANUAL > /dev/null 2>&1 & disown
        echo "manual" > "$STATE_FILE"
        ;;
    *"Extra"*)
        hyprsunset --temperature $TEMP_EXTRA > /dev/null 2>&1 & disown
        echo "manual" > "$STATE_FILE"
        ;;
    *"Off"*)
        echo "off" > "$STATE_FILE"
        ;;
esac

# Update UI components
pkill -SIGRTMIN+8 waybar 2>/dev/null
swaync-client -rs # Reload CSS/Config to trigger button updates without full restart
swaync-client -cp # Close panel
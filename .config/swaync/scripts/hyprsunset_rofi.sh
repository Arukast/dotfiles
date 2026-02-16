#!/bin/bash

# Konfigurasi
TEMP_MANUAL=5000
TEMP_EXTRA=3500
STATE_FILE="/tmp/hyprsunset_mode"

# Menu Rofi
options="🕒 Auto\n🌙 Manual ($TEMP_MANUAL K)\n🔥 Extra Warm ($TEMP_EXTRA K)\n☀️ Off"

# Tampilkan Rofi
selected=$(echo -e "$options" | rofi -dmenu -p "Night Light" -lines 4 -width 20)

case "$selected" in
    *"Auto"*)
        pkill -x hyprsunset
        hyprsunset > /dev/null 2>&1 & disown
        echo "auto" > "$STATE_FILE"
        ;;
    *"Manual"*)
        pkill -x hyprsunset
        hyprsunset --temperature $TEMP_MANUAL > /dev/null 2>&1 & disown
        echo "manual" > "$STATE_FILE"
        ;;
    *"Extra"*)
        pkill -x hyprsunset
        hyprsunset --temperature $TEMP_EXTRA > /dev/null 2>&1 & disown
        echo "manual" > "$STATE_FILE"
        ;;
    *"Off"*)
        pkill -x hyprsunset
        echo "off" > "$STATE_FILE"
        ;;
esac

# Update Waybar/SwayNC segera setelah memilih
pkill -SIGRTMIN+8 waybar
swaync-client -R
swaync-client -cp # Tutup panel notifikasi setelah memilih
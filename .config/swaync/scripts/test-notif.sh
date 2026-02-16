#!/bin/bash
echo "Sending notifications..."

# Normal
notify-send "System" "Welcome back, User!" -i computer

# Critical
sleep 1
notify-send -u critical "Battery Low" "Connect charger immediately (15%)" -i battery-caution

# Image
sleep 1
notify-send "Music Player" "Now Playing: Lofi Hip Hop" -i multimedia-player --hint=string:image-path:/usr/share/icons/Adwaita/256x256/places/folder-music.png

# Progress
sleep 1
notify-send "Brightness" "75%" -h int:value:75 -h string:synchronous:brightness

# Action (Check terminal output)
sleep 1
notify-send "Update Available" "Download now?" --action="yes=Yes" --action="no=No"

echo "Done."
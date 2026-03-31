#!/bin/bash

options="1. Default (Semua Layar Menyala)\n2. Mirror (Native Hyprland)\n3. Laptop Only\n4. External Only (HDMI & DP-2 Saja)"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Mode Layar:" -l 4)

case "$chosen" in
    "1. Default (Semua Layar Menyala)")
        hyprctl keyword monitor "eDP-1, preferred, auto, 1"
        hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1"
        hyprctl keyword monitor "DP-2, preferred, auto, 1"
        hyprctl reload
        ;;
        
    "2. Mirror (Native Hyprland)")
        hyprctl keyword monitor "eDP-1, preferred, auto, 1"
        hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
        hyprctl keyword monitor "DP-2, preferred, auto, 1"
        ;;
        
    "3. Laptop Only")
        hyprctl keyword monitor "eDP-1, preferred, auto, 1"
        hyprctl keyword monitor "HDMI-A-1, disable"
        hyprctl keyword monitor "DP-2, disable"
        ;;
        
    "4. External Only (HDMI & DP-2 Saja)")
        hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1"
        hyprctl keyword monitor "DP-2, preferred, auto, 1"
        hyprctl keyword monitor "eDP-1, disable"
        ;;
        
    *)
        exit 0
        ;;
esac

# TUNGGU LEBIH LAMA: Waktu krusial 2 detik untuk dGPU NVIDIA mengenali HDMI-A-1
sleep 2

# REFRESH WAYBAR SECARA AMAN
killall waybar 2>/dev/null
sleep 0.5

waybar > /dev/null 2>&1 &

# REFRESH SWWW TANPA MEMBUNUH DAEMON
# Pastikan daemon berjalan di latar belakang (jika sebelumnya tidak sengaja mati)
awww-daemon > /dev/null 2>&1 &
sleep 0.5

# Paksa swww menggambar ulang wallpaper di semua monitor yang aktif.
# UBAH LOKASI FILE DI BAWAH INI SESUAI WALLPAPER KAMU:
awww img $HOME/Pictures/Wallpapers/redbull3.png --transition-type none > /dev/null 2>&1 &
#!/bin/bash

options="1. Default (Semua Layar Menyala)\n2. Mirror (Monitor Kos / Native 1080p)\n3. Laptop Only\n4. External Only (HDMI & DP-2 Saja)\n5. Proyektor / Presentasi (UI Lebih Kecil)\n6. Mirror Proyektor (Resolusi 720p agar tidak buram)"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Mode Layar:" -l 6)

case "$chosen" in
    "1. Default (Semua Layar Menyala)")
        # Karena proyektor sudah punya menu sendiri, kita bisa dengan aman menggunakan 'reload' 
        # untuk memuat ulang konfigurasi nwg-displays (monitors.conf) secara sempurna termasuk refresh rate 180Hz.
        hyprctl reload
        ;;
        
    "2. Mirror (Monitor Kos / Native 1080p)")
        # Mirror normal untuk monitor eksternal di kos (resolusi asli 1080p)
        hyprctl --batch "keyword monitor eDP-1, 1920x1080, auto, 1; keyword monitor HDMI-A-1, 1920x1080, auto, 1, mirror, eDP-1; keyword monitor DP-2, 1920x1080, auto, 1, mirror, eDP-1"
        ;;
        
    "3. Laptop Only")
        hyprctl --batch "keyword monitor eDP-1, preferred, auto, 1; keyword monitor HDMI-A-1, disable; keyword monitor DP-2, disable"
        ;;
        
    "4. External Only (HDMI & DP-2 Saja)")
        hyprctl --batch "keyword monitor HDMI-A-1, preferred, auto, 1; keyword monitor DP-2, preferred, auto, 1; keyword monitor eDP-1, disable"
        ;;
    
    "5. Proyektor / Presentasi (UI Lebih Kecil)")
        hyprctl --batch "keyword monitor eDP-1, preferred, 0x0, 1; keyword monitor HDMI-A-1, preferred, 1920x0, 0.8; keyword monitor DP-2, preferred, 4320x0, 1"
        ;;

    "6. Mirror Proyektor (Resolusi 720p agar tidak buram)")
        # Menurunkan resolusi kedua layar ke 720p khusus untuk proyektor
        # Jika teks masih kurang pas, ganti "1280x720" menjadi "1366x768"
        hyprctl --batch "keyword monitor eDP-1, 1280x720, auto, 1; keyword monitor HDMI-A-1, 1280x720, auto, 1, mirror, eDP-1; keyword monitor DP-2, 1280x720, auto, 1, mirror, eDP-1"
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
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon > /dev/null 2>&1 &
    sleep 0.5
fi

# Paksa swww menggambar ulang wallpaper di semua monitor yang aktif.
# UBAH LOKASI FILE DI BAWAH INI SESUAI WALLPAPER KAMU:
awww img $HOME/Pictures/Wallpapers/redbull3.png --transition-type none > /dev/null 2>&1 &
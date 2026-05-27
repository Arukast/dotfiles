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
        hyprctl --batch "eval hl.monitor({ output = 'eDP-1', mode = '1920x1080', position = 'auto', scale = 1 }); eval hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080', position = 'auto', scale = 1, mirror = 'eDP-1' }); eval hl.monitor({ output = 'DP-2', mode = '1920x1080', position = 'auto', scale = 1, mirror = 'eDP-1' })"
        ;;
        
    "3. Laptop Only")
        hyprctl --batch "eval hl.monitor({ output = 'eDP-1', mode = 'preferred', position = 'auto', scale = 1 }); eval hl.monitor({ output = 'HDMI-A-1', disabled = true }); eval hl.monitor({ output = 'DP-2', disabled = true })"
        ;;
        
    "4. External Only (HDMI & DP-2 Saja)")
        hyprctl --batch "eval hl.monitor({ output = 'HDMI-A-1', mode = 'preferred', position = 'auto', scale = 1 }); eval hl.monitor({ output = 'DP-2', mode = 'preferred', position = 'auto', scale = 1 }); eval hl.monitor({ output = 'eDP-1', disabled = true })"
        ;;
    
    "5. Proyektor / Presentasi (UI Lebih Kecil)")
        hyprctl --batch "eval hl.monitor({ output = 'eDP-1', mode = 'preferred', position = '0x0', scale = 1 }); eval hl.monitor({ output = 'HDMI-A-1', mode = 'preferred', position = '1920x0', scale = 0.8 }); eval hl.monitor({ output = 'DP-2', mode = 'preferred', position = '4320x0', scale = 1 })"
        ;;

    "6. Mirror Proyektor (Resolusi 720p agar tidak buram)")
        # Menurunkan resolusi kedua layar ke 720p khusus untuk proyektor
        # Jika teks masih kurang pas, ganti "1280x720" menjadi "1366x768"
        hyprctl --batch "eval hl.monitor({ output = 'eDP-1', mode = '1280x720', position = 'auto', scale = 1 }); eval hl.monitor({ output = 'HDMI-A-1', mode = '1280x720', position = 'auto', scale = 1, mirror = 'eDP-1' }); eval hl.monitor({ output = 'DP-2', mode = '1280x720', position = 'auto', scale = 1, mirror = 'eDP-1' })"
        ;;
    *)
        exit 0
        ;;
esac

# TUNGGU LEBIH LAMA: Waktu krusial 2 detik untuk dGPU NVIDIA mengenali HDMI-A-1
sleep 2

# REFRESH WAYBAR SECARA AMAN VIA SYSTEMD
systemctl --user restart waybar.service


# REFRESH SWWW TANPA MEMBUNUH DAEMON
# Pastikan daemon berjalan di latar belakang (jika sebelumnya tidak sengaja mati)
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon > /dev/null 2>&1 &
    sleep 0.5
fi

# Paksa swww menggambar ulang wallpaper di semua monitor yang aktif.
# UBAH LOKASI FILE DI BAWAH INI SESUAI WALLPAPER KAMU:
awww img $HOME/Pictures/Wallpapers/redbull3.png --transition-type none > /dev/null 2>&1 &
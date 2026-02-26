#!/bin/bash

# Identitas proses yang akan kita jalankan untuk memblokir suspend
# Kita menggunakan nama yang unik agar mudah dicari (grep)
INHIBIT_CMD="systemd-inhibit --what=sleep --who=SwayNC --why=CaffeineMode --mode=block sleep infinity"

case "$1" in
    toggle)
        if pgrep -f "$INHIBIT_CMD" > /dev/null; then
            # Jika sedang berjalan, matikan (Kill)
            pkill -f "$INHIBIT_CMD"
            notify-send -u low -r 9981 "Caffeine Mode: OFF" "Suspend/Sleep diaktifkan kembali" -i "coffee-off-outline"
        else
            # Jika mati, jalankan di background (&)
            $INHIBIT_CMD > /dev/null 2>&1 & disown
            notify-send -u low -r 9981 "Caffeine Mode: ON" "PC tidak akan tidur (Layar tetap bisa mati)" -i "coffee-outline"
        fi
        ;;
    status)
        # Cek status untuk SwayNC (True/False)
        if pgrep -f "$INHIBIT_CMD" > /dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
esac
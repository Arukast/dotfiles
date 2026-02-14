#!/bin/bash

# Cek apakah ada perangkat yang NYALA (Soft blocked: no)
# Jika ada yang "no", berarti Airplane Mode = OFF (False)
# Jika semua "yes", berarti Airplane Mode = ON (True)
IS_AIRPLANE_OFF=$(rfkill list | grep "Soft blocked: no")

case "$1" in
    "toggle")
        if [ -n "$IS_AIRPLANE_OFF" ]; then
            # Ada perangkat nyala -> Matikan semua (Mode Pesawat ON)
            rfkill block all
        else
            # Semua mati -> Nyalakan semua (Mode Pesawat OFF)
            rfkill unblock all
        fi
        ;;
    "status")
        if [ -n "$IS_AIRPLANE_OFF" ]; then
            echo "false" # Tombol Mati (Wifi Nyala)
        else
            echo "true"  # Tombol Nyala (Wifi Mati/Blocked)
        fi
        ;;
esac
#!/bin/bash

CONF_DIR="$HOME/.config/hypr"
CURRENT_LINK="$CONF_DIR/custom/env_current.conf"
BATTERY_CONF="$CONF_DIR/custom/env_battery.conf"
DESK_CONF="$CONF_DIR/custom/env_desk.conf"

# Deteksi string "mesa" pada baris GLX_VENDOR_LIBRARY_NAME
if grep -q "__GLX_VENDOR_LIBRARY_NAME,mesa" "$CURRENT_LINK"; then
    # Jika saat ini baterai, ubah ke desk
    cp "$DESK_CONF" "$CURRENT_LINK"
    notify-send -u critical "GPU Mode" "Mode Desk (NVIDIA ON) aktif.\nSilakan Logout (Super+M) untuk menerapkan."
else
    # Jika saat ini desk, ubah ke baterai
    cp "$BATTERY_CONF" "$CURRENT_LINK"
    notify-send -u critical "GPU Mode" "Mode Baterai (NVIDIA OFF) aktif.\nSilakan Logout (Super+M) untuk menerapkan."
fi
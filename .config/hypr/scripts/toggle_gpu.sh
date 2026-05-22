#!/bin/bash

OVERRIDE_FILE="$HOME/.config/uwsm/env_gpu_override"

# Check if --reset parameter is passed
if [ "$1" = "--reset" ]; then
    rm -f "$OVERRIDE_FILE"
    notify-send -u normal -r 9983 -h string:x-canonical-private-synchronous:gpu "GPU Mode" "Mode otomatis (Auto Boot-detection) diaktifkan kembali.\nSilakan Logout (Super+M) jika diperlukan."
    exit 0
fi

# 1. Determine active GPU driver name (current environment variable)
ACTIVE_GPU="$__GLX_VENDOR_LIBRARY_NAME"

# 2. Toggle the override state
if [ "$ACTIVE_GPU" = "mesa" ]; then
    # Switch to NVIDIA (Desk Mode)
    echo 'export GPU_MODE="nvidia"' > "$OVERRIDE_FILE"
    notify-send -u critical -r 9983 -h string:x-canonical-private-synchronous:gpu "GPU Mode (Forced)" "Mode Desk (NVIDIA ON) dipaksa aktif.\nSilakan Logout (Super+M) untuk menerapkan."
else
    # Switch to AMD/Mesa (Battery Mode)
    echo 'export GPU_MODE="mesa"' > "$OVERRIDE_FILE"
    notify-send -u critical -r 9983 -h string:x-canonical-private-synchronous:gpu "GPU Mode (Forced)" "Mode Baterai (NVIDIA OFF) dipaksa aktif.\nSilakan Logout (Super+M) untuk menerapkan."
fi
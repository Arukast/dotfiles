#!/bin/env bash

# Wait a short moment for systemd user services to settle
sleep 2.0

# Check if HDMI-A-1 is connected/detected
if hyprctl monitors all | grep -q "HDMI-A-1"; then
    # Disable HDMI-A-1 via Lua config state (tells Hyprland to clear its allocation)
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
    
    # Wait a tiny moment for the GPU driver/bus to settle
    sleep 0.5
    
    # Reload the configuration to re-read monitors.conf, re-enable the screen, and force a fresh modeset
    hyprctl reload
fi

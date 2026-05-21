#!/bin/env bash

# Wait for Hyprland session and dGPU initialization to settle
sleep 4

# Check if HDMI-A-1 is connected/detected
if hyprctl monitors all | grep -q "HDMI-A-1"; then
    # Disable the HDMI-A-1 monitor via Hyprland's Lua API
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
    
    # Wait a moment for the dGPU state to reset
    sleep 1.5
    
    # Reload the configuration to re-enable HDMI-A-1 with its default settings from monitors.conf
    hyprctl reload
fi

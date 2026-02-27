#!/bin/sh

handle() {
  case $1 in monitoradded*)
    # Memindahkan workspace 4-6 ke monitor HDMI saat dicolok
    hyprctl dispatch moveworkspacetomonitor 5 HDMI-A-1
    hyprctl dispatch moveworkspacetomonitor 6 HDMI-A-1
    hyprctl dispatch moveworkspacetomonitor 7 HDMI-A-1
    
    # Memindahkan workspace 7-9 ke monitor DP saat dicolok
    hyprctl dispatch moveworkspacetomonitor 8 DP-2
    hyprctl dispatch moveworkspacetomonitor 9 DP-2
    hyprctl dispatch moveworkspacetomonitor 10 DP-2

    # Memaksa Waybar merender ulang UI di layar baru
    killall -SIGUSR2 waybar
  esac
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
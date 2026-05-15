#!/bin/sh

handle() {
  case $1 in monitoradded*)
    # Pindahkan workspace ke monitor eksternal dalam satu batch command
    hyprctl --batch "dispatch moveworkspacetomonitor 5 HDMI-A-1; dispatch moveworkspacetomonitor 6 HDMI-A-1; dispatch moveworkspacetomonitor 7 HDMI-A-1; dispatch moveworkspacetomonitor 8 DP-2; dispatch moveworkspacetomonitor 9 DP-2; dispatch moveworkspacetomonitor 10 DP-2"

    # Refresh Waybar
    killall waybar 2>/dev/null

    # Tunggu sepersekian detik agar Hyprland selesai merender monitor baru
    sleep 0.2

    # Jalankan kembali Waybar dan buang log-nya agar tidak nyangkut di terminal
    waybar > /dev/null 2>&1 &
  esac
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
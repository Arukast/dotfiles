#!/bin/sh

handle() {
  case $1 in monitoradded*)
    # Pindahkan workspace ke HDMI
    for i in 5 6 7; do hyprctl dispatch moveworkspacetomonitor $i HDMI-A-1; done
    
    # Pindahkan workspace ke DP-2
    for i in 8 9 10; do hyprctl dispatch moveworkspacetomonitor $i DP-2; done

    # Refresh Waybar
    killall waybar 2>/dev/null

    # Tunggu sepersekian detik agar Hyprland selesai merender monitor baru
    sleep 0.2

    # Jalankan kembali Waybar dan buang log-nya agar tidak nyangkut di terminal
    waybar > /dev/null 2>&1 &
  esac
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
#!/usr/bin/env fish

# --- Update Function ---
set -l blue (set_color -o blue)
set -l green (set_color -o green)
set -l normal (set_color normal)

echo -e "\n$blue── Updating pacman packages ──$normal"
sudo pacman -Syu

if command -v yay > /dev/null
    echo -e "\n$blue── Updating AUR packages (yay) ──$normal"
    yay -Syu
else if command -v paru > /dev/null
    echo -e "\n$blue── Updating AUR packages (paru) ──$normal"
    paru -Syu
end

if command -v flatpak > /dev/null
    echo -e "\n$blue── Updating Flatpak packages ──$normal"
    flatpak update
end

# if command -v hyprpm > /dev/null
#     echo -e "\n$blue── Updating Hyprland plugins ──$normal"
#     hyprpm update && hyprpm reload
# end

# Update Waybar module if running
# if pgrep waybar > /dev/null
#     pkill -RTMIN+1 waybar
# end

echo -e "\n$green── System Update Complete ──$normal\n"

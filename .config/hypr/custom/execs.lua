local statusBar = "waybar"
local wallpaper = "awww-daemon & sleep 0.1 && awww img $HOME/Pictures/Wallpapers/redbull3.png"
local authenticationAgent = "systemctl --user start hyprpolkitagent"
local idleSystem = "hypridle"
local blueLightFilter = "hyprsunset"
local autoMounting = "udiskie"
local clipboardManager = "wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & wl-clip-persist --clipboard regular"

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP __GLX_VENDOR_LIBRARY_NAME __EGL_VENDOR_LIBRARY_FILENAMES VK_DRIVER_FILES")
    hl.exec_cmd("aa-notify -p -s 10 -w 60 -f /var/log/audit/audit.log")
    hl.exec_cmd("sleep 2; " .. statusBar .. " & " .. wallpaper)
    hl.exec_cmd("sleep 3; " .. authenticationAgent .. " & " .. idleSystem .. " & " .. blueLightFilter .. " & " .. autoMounting .. " & " .. clipboardManager)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("sleep 4; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && discord --start-minimized &> /dev/null &'")
    hl.exec_cmd("sleep 4; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && spotify-launcher &> /dev/null &'")
    hl.exec_cmd("sleep 4; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && steam -silent &> /dev/null &'")
    -- Also start notification daemon
    hl.exec_cmd("swaync")
end)

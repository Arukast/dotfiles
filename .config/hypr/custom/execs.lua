-- =============================================================================
-- HYPRLAND CUSTOM EXECUTION CONFIGURATION (UWSM/SYSTEMD INTEGRATION)
-- =============================================================================

-- Non-systemd background daemons and utilities (wrapped in 'uwsm app --' for scope isolation)
local wallpaper = "uwsm app -- awww-daemon & sleep 0.2 && uwsm app -- awww img $HOME/Pictures/Wallpapers/redbull3.png"
local autoMounting = "uwsm app -- udiskie"
local clipboardManager = "uwsm app -- wl-paste --type text --watch cliphist store & uwsm app -- wl-paste --type image --watch cliphist store & uwsm app -- wl-clip-persist --clipboard regular"
local polkit = "uwsm app -- /usr/lib/polkit-kde-authentication-agent-1"

hl.on("hyprland.start", function()
    -- Native plugins & low-level notifier
    hl.exec_cmd("uwsm app -- hyprpm reload -n")
    hl.exec_cmd("uwsm app -- aa-notify -p -s 10 -w 60 -f /var/log/audit/audit.log")
    
    -- Launch wallpaper daemon & mount tools
    hl.exec_cmd("sleep 1; " .. wallpaper)
    hl.exec_cmd("sleep 2; " .. autoMounting .. " & " .. clipboardManager .. " & " .. polkit)
    
    -- Consistent GTK/GNOME Dark Theme Settings
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    
    -- Heavy applications (AC power only - starts delayed, wrapped in UWSM scopes)
    hl.exec_cmd("sleep 3; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && uwsm app -- discord --start-minimized &> /dev/null &'")
    hl.exec_cmd("sleep 3; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && uwsm app -- spotify-launcher &> /dev/null &'")
    hl.exec_cmd("sleep 3; sh -c 'grep -q 1 /sys/class/power_supply/AC*/online && uwsm app -- steam -silent &> /dev/null &'")
    
    -- Workaround to initialize HDMI monitor on Nvidia dGPU without causing freezes
    hl.exec_cmd("uwsm app -- /home/arukast/.config/hypr/scripts/fix_nvidia_monitor.sh &")
end)

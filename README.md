# Arukast Dotfiles

This repository contains configuration files (dotfiles) for an Arch Linux environment with a Wayland-based ecosystem. This setup is focused on utilizing Hyprland as the primary compositor, with integrated custom tools to enhance desktop productivity and aesthetics.

## System Components

| Category | Software | Description |
| :--- | :--- | :--- |
| **Window Manager** | Hyprland | Includes configurations for `hypridle`, `hyprlock`, and `hyprsunset`, as well as multi-monitor management. |
| **Status Bar** | Waybar | Features two design iterations (`ArukastWaybarVer1` and `ArukastWaybarVer2`) with custom modules for system, media, and updates. |
| **App Launcher** | Rofi | Equipped with various applet scripts (battery, brightness, volume, screenshot) and multiple power menu variations. |
| **Terminal** | Kitty | High-performance configuration featuring scroll navigation and Python-based search scripts. |
| **Shell & Prompt** | Fish & Starship | Interactive command-line environment with auto-completion and prompt appearance modifications. |
| **Notifications** | SwayNC | Notification control center with custom color schemes and quick control scripts. |
| **GPU Management** | Custom Scripts | Hardware control scripts for NVIDIA (`nvidia-undervolt.py`, `nvidia-run`) and a GPU toggler (`toggle_gpu.sh`) located in `.local/bin/scripts`. |

## Repository Structure

The `.config` directory contains the majority of application and user interface configurations. The `.local/bin/scripts` directory serves as the storage location for system utility scripts, including automated backup tools. The `Dotfiles Misc` directory provides additional specific configurations, such as `user.js` for the Firefox browser and `reflector.conf` for Arch Linux mirror server management.

## Basic Installation

Move or create a symbolic link (symlink) from the `.config` and `.local` directories in this repository into the `~` (Home) directory on your local system. Ensure all packages and dependencies relevant to the components above are installed on your Arch Linux system to prevent script execution failures or interface loading issues.

## Crucial Post-Installation & System Tweaks

To ensure all custom tools, status bars, and widgets function flawlessly without crashing or permission issues, apply these post-install system tweaks:

### 1. Additional Required Packages
Make sure these packages are installed alongside the core applications:
```bash
# Core utilities and helpers
sudo pacman -S --needed gvfs blueman gamemode lib32-gamemode ydotool

# NetworkManager dmenu launcher (AUR)
yay -S networkmanager-dmenu-git
```
*(Note: `gvfs` is required for GLib/GIO to fetch remote cover art for the SwayNC MPRIS player widget).*

### 2. Backlight Control Permissions (Udev Rule)
SwayNC's backlight slider writes directly to `/sys/class/backlight/.../brightness`. By default, this file is only writeable by root. Create a Udev rule to grant the `video` group (which your user is in) write permissions:
```bash
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/usr/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/usr/bin/chmod g+w /sys/class/backlight/%k/brightness"' | sudo tee /etc/udev/rules.d/99-backlight.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 3. VS Code KWallet 6 Integration (No GNOME Bloat)
Instead of installing GNOME keyring dependencies in a pure Plasma/Hyprland environment, configure VS Code to store passwords natively inside your KDE KWallet 6 database:
1. Append this flag to your `~/.config/code-flags.conf` file:
   ```ini
   --password-store=kwallet6
   ```

### 4. Waybar Boot Stability (Systemd User Override)
Under UWSM / systemd user services, Waybar may occasionally launch before the graphical environment has fully initialized, causing it to crash at boot. Create a systemd user drop-in override to delay startup and auto-recover on failures:
1. Create `~/.config/systemd/user/waybar.service.d/override.conf`:
   ```ini
   [Service]
   ExecStartPre=/usr/bin/sleep 2
   Restart=on-failure
   RestartSec=3
   ```
2. Reload systemd user configuration:
   ```bash
   systemctl --user daemon-reload
   ```

### 5. Windows Dual-Boot Time Desync Fix
To prevent Windows and Linux clocks from drifting out of sync:
```bash
sudo timedatectl set-timezone Asia/Jakarta
sudo timedatectl set-local-rtc 1 --adjust-system-clock
```


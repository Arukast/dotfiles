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

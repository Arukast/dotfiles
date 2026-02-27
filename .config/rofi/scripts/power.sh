#!/usr/bin/env bash

if [ -n "$1" ]; then
    case "$1" in
        "Power Off") systemctl poweroff ;;
        "Reboot") systemctl reboot ;;
        "Suspend") systemctl suspend ;;
        "Lock") hyprlock ;;
        "Logout") hyprctl dispatch exit ;;
    esac
    exit 0
fi

echo -e "Lock\0icon\x1fsystem-lock-screen-symbolic"
echo -e "Suspend\0icon\x1fsystem-suspend-symbolic"
echo -e "Logout\0icon\x1fsystem-log-out-symbolic"
echo -e "Reboot\0icon\x1fsystem-reboot-symbolic"
echo -e "Power Off\0icon\x1fsystem-shutdown-symbolic"
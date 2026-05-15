#!/bin/bash

# Prevent system from sleeping/suspending
# Using a unique name for pgrep reliability

INHIBIT_CMD="systemd-inhibit --what=sleep --who=SwayNC --why=Caffeine --mode=block sleep infinity"

is_active() {
    pgrep -f "Caffeine --mode=block sleep infinity" > /dev/null
}

case "$1" in
    toggle)
        if is_active; then
            pkill -f "Caffeine --mode=block sleep infinity"
            notify-send -u low -r 9981 -h string:x-canonical-private-synchronous:caffeine "Caffeine Mode: OFF" "Suspend/Sleep enabled" -i "coffee-off-outline"
        else
            $INHIBIT_CMD > /dev/null 2>&1 & disown
            notify-send -u low -r 9981 -h string:x-canonical-private-synchronous:caffeine "Caffeine Mode: ON" "System will stay awake" -i "coffee-outline"
        fi
        ;;
    status)
        if is_active; then
            echo "true"
        else
            echo "false"
        fi
        ;;
esac
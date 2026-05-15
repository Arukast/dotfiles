#!/bin/bash

# Fast and robust airplane mode check using rfkill JSON output
# Returns "true" if ALL devices are soft-blocked (Airplane Mode ON)
# Returns "false" if ANY device is unblocked (Airplane Mode OFF)

get_status() {
    if rfkill --json | jq -e '.rfkilldevices[].soft == "unblocked"' > /dev/null; then
        echo "false"
    else
        echo "true"
    fi
}

case "$1" in
    "toggle")
        if [ "$(get_status)" == "false" ]; then
            # Airplane Mode OFF -> Turn it ON
            rfkill block all
            notify-send -u low -r 9982 -h string:x-canonical-private-synchronous:airplane "Airplane Mode: ON" "All wireless devices disabled" -i "airplane-mode-on"
        else
            # Airplane Mode ON -> Turn it OFF
            rfkill unblock all
            notify-send -u low -r 9982 -h string:x-canonical-private-synchronous:airplane "Airplane Mode: OFF" "Wireless devices enabled" -i "airplane-mode-off"
        fi
        ;;
    "status")
        get_status
        ;;
esac
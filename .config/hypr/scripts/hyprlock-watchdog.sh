#!/usr/bin/env bash

# Prevent starting multiple watchdog instances
if pidof -x "hyprlock-watchdog.sh" -o $$ >/dev/null; then
    echo "Watchdog already running. Exiting."
    exit 0
fi

# Ensure we don't conflict if hyprlock is already running
if pidof hyprlock >/dev/null; then
    echo "hyprlock is already running. Exiting."
    exit 0
fi

echo "Starting hyprlock watchdog loop..."

while true; do
    # Run hyprlock with immediate render
    hyprlock --immediate-render
    
    EXIT_CODE=$?
    
    # If the exit code is 0, the user unlocked successfully!
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Successfully unlocked. Stopping watchdog."
        break
    fi
    
    # If it was terminated by SIGTERM (143) or SIGINT (130) (e.g. system suspending/rebooting), exit
    if [ $EXIT_CODE -eq 143 ] || [ $EXIT_CODE -eq 130 ]; then
        echo "Terminated by system. Stopping watchdog."
        break
    fi
    
    # If we are no longer in a locked state (e.g. unlocked through loginctl unlock-session), exit
    # We can check if hyprlock is really needed by checking if we are still active.
    # But checking if the lock session is still active via loginctl is a great fallback.
    if loginctl show-session self 2>/dev/null | grep -q "LockedHint=no"; then
        echo "Session is unlocked according to logind. Stopping watchdog."
        break
    fi
    
    echo "hyprlock crashed or exited unexpectedly with code $EXIT_CODE. Restarting in 0.3 seconds..."
    sleep 0.3
done

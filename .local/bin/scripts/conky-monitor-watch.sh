#!/usr/bin/env bash

echo "Initializing Conky Native Wayland Monitor Watcher..."
sleep 2

launch_conky() {
    echo "Scanning active hardware screens..."
    killall conky 2>/dev/null
    sleep 1

    BASE_CONF="$HOME/.config/conky/conky.conf"
    if [ ! -f "$BASE_CONF" ]; then
        echo "Error: Base conky.conf not found at $BASE_CONF"
        return
    fi

    # Natively count enabled displays
    MONITOR_COUNT=$(kscreen-doctor -o 2>/dev/null | grep -c "enabled")

    if [ "$MONITOR_COUNT" -eq 0 ]; then
        echo "Error: No screens detected. Spawning default fallback."
        conky -c "$BASE_CONF" &
        return
    fi

    # Spawning Conky instances across monitors using XWayland (required for multi-monitor positioning on KWin Wayland)
    # xinerama_head is zero-indexed in Conky (0 = first monitor, 1 = second, etc.)
    for i in $(seq 0 $((MONITOR_COUNT - 1))); do
        TMP_CONF="/tmp/conky_screen_${i}.conf"
        cp "$BASE_CONF" "$TMP_CONF"

        # Strip any existing head assignments, Wayland output flags, and own_window_type
        sed -i '/xinerama_head/d' "$TMP_CONF"
        sed -i '/out_to_wayland/d' "$TMP_CONF"
        sed -i '/out_to_x/d' "$TMP_CONF"
        sed -i '/own_window_type/d' "$TMP_CONF"

        # Inject XWayland settings, head assignments, and normal window type (keeps Conky below other windows without duplicating)
        sed -i "s/conky.config[[:space:]]*=[[:space:]]*{/conky.config = {\n    out_to_wayland = false,\n    out_to_x = true,\n    own_window_type = 'normal',\n    xinerama_head = $i,/g" "$TMP_CONF"

        echo "Spawning Conky instance locked to Screen $i (xinerama_head=$i) via XWayland"
        conky -c "$TMP_CONF" &
    done
}

launch_conky

LAST_COUNT=$(kscreen-doctor -o 2>/dev/null | grep -c "enabled")

echo "Background monitoring loop active. Watching for monitor state changes..."
while true; do
    sleep 4
    CURRENT_COUNT=$(kscreen-doctor -o 2>/dev/null | grep -c "enabled")
    if [ "$CURRENT_COUNT" -ne "$LAST_COUNT" ]; then
        echo "Display hardware state mutation detected! Recalculating workspace mapping..."
        launch_conky
        LAST_COUNT=$CURRENT_COUNT
    fi
done

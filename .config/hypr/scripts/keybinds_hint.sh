#!/bin/bash

# Path to your keybinds config
CONFIG_FILE="$HOME/.config/hypr/custom/keybinds.conf"
# Rofi theme directory
THEME_DIR="$HOME/.config/rofi/launchers"
THEME="style.rasi"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    notify-send "Error" "Keybinds config not found at $CONFIG_FILE"
    exit 1
fi

# Parse, Weight, and Sort keybinds for rofi
# We use a weight prefix (e.g. 10|) to sort categories by importance
list=$(awk -v blue="#61AFEF" -v grey="#7f848e" '
    # Function to escape special characters for Pango markup
    function escape(str) {
        gsub(/&/, "&amp;", str)
        gsub(/</, "&lt;", str)
        gsub(/>/, "&gt;", str)
        return str
    }
    BEGIN { section = "General" }
    /^##!/ { section = substr($0, 5); next }
    /^(bind|binde|bindl|bindm|bindd|bindel|bindld)/ {
        line = $0
        
        # Extract mods and key
        content = line
        sub(/^[a-z]+ *= */, "", content)
        split(content, parts, ",")
        
        mods_raw = parts[1]
        key_raw = parts[2]
        
        # Description extraction
        desc = ""
        if (line ~ /^bindd/) {
            desc = parts[3]
        } else if (line ~ /#/) {
            split(line, comment, "#")
            desc = comment[2]
        }
        gsub(/^ */, "", desc); gsub(/ *$/, "", desc)

        if (desc ~ /\[hidden\]/ || desc == "") next

        # Importance Weighting (Requested: Special #3, Utilities #4, Workspace Last)
        weight = 99
        if (section ~ /Apps/) weight = 10
        else if (section ~ /Window/) weight = 20
        else if (section ~ /Special/) weight = 30
        else if (section ~ /Utilities/) weight = 40
        else if (section ~ /System/) weight = 50
        else if (section ~ /Media/) weight = 60
        else if (section ~ /Workspace/) weight = 70

        # --- Humanize Mods ---
        m = mods_raw
        gsub(/\$mainMod/, "SUPER", m)
        gsub(/SHIFT|Shift/, "Shift", m)
        gsub(/CTRL|Ctrl/, "Ctrl", m)
        gsub(/ALT|Alt/, "Alt", m)
        gsub(/[ \+]/, "", m)
        
        res_m = ""
        if (m ~ /SUPER/) res_m = res_m "SUPER + "
        if (m ~ /Ctrl/) res_m = res_m "Ctrl + "
        if (m ~ /Alt/) res_m = res_m "Alt + "
        if (m ~ /Shift/) res_m = res_m "Shift + "
        
        # --- Humanize Keys ---
        k = key_raw
        gsub(/ /, "", k)
        gsub(/mouse:272/, "LMB", k)
        gsub(/mouse:273/, "RMB", k)
        gsub(/mouse:274/, "MMB", k)
        gsub(/mouse:275/, "Side1", k)
        gsub(/mouse:276/, "Side2", k)
        gsub(/mouse_up/, "WheelUp", k)
        gsub(/mouse_down/, "WheelDown", k)
        
        gsub(/XF86AudioRaiseVolume/, "Vol+", k)
        gsub(/XF86AudioLowerVolume/, "Vol-", k)
        gsub(/XF86AudioMute/, "Mute", k)
        gsub(/XF86AudioMicMute/, "MicMute", k)
        gsub(/XF86MonBrightnessUp/, "Bright+", k)
        gsub(/XF86MonBrightnessDown/, "Bright-", k)
        gsub(/XF86AudioPlay/, "Play/Pause", k)
        gsub(/XF86AudioPause/, "Play/Pause", k)
        gsub(/XF86AudioNext/, "Next", k)
        gsub(/XF86AudioPrev/, "Prev", k)
        gsub(/Print|PRINT/, "PrintScreen", k)
        gsub(/grave/, "`", k)
        
        # Combine mods and key nicely
        full_shortcut = (res_m != "" ? res_m k : k)

        # Nerd Font Glyph mapping
        glyph = ""
        if (section ~ /Apps/) glyph = ""
        else if (section ~ /Window/) glyph = ""
        else if (section ~ /Workspace/) glyph = ""
        else if (section ~ /Special/) glyph = ""
        else if (section ~ /System/) glyph = ""
        else if (section ~ /Media/) glyph = ""
        else if (section ~ /Utilities/) glyph = "🛠"

        # Pango Markup
        icon_span = "<span color=\"" blue "\">" glyph "</span>"
        shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(full_shortcut) "</span>"
        description_span = "<span>" escape(desc) "</span>"
        category_span = "<span color=\"" grey "\" size=\"small\">[" escape(section) "]</span>"
        
        # Format for sorting: Weight|Icon  Shortcut │ Description │ [Section]
        printf "%d|%s  %s │ %s │ %s\n", weight, icon_span, shortcut_span, description_span, category_span
    }
' "$CONFIG_FILE" | sort -n | cut -d'|' -f2-)

# Show in Rofi
echo -e "$list" | rofi -dmenu -i -p "Shortcuts" \
    -markup-rows \
    -theme "${THEME_DIR}/${THEME}" \
    -theme-str '
        window { width: 1100px; border-radius: 15px; }
        listview { lines: 14; columns: 1; spacing: 4px; }
        element { padding: 5px 15px; }
        element-icon { enabled: false; }
        element-text { markup: true; vertical-align: 0.5; }
        element selected.normal { background-color: #3E4452; text-color: #FFFFFF; }
    '

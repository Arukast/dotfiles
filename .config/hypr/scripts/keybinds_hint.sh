#!/bin/bash

# Path to your keybinds config (LUA EDITION)
CONFIG_FILE="$HOME/.config/hypr/custom/keybinds.lua"
# Rofi theme directory
THEME_DIR="$HOME/.config/rofi/launchers"
THEME="style.rasi"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    notify-send "Error" "Keybinds config not found at $CONFIG_FILE"
    exit 1
fi

# Parse, Weight, and Sort keybinds for rofi
list=$(awk -v blue="#61AFEF" -v grey="#7f848e" '
    # Function to escape special characters for Pango markup
    function escape(str) {
        gsub(/&/, "&amp;", str)
        gsub(/</, "&lt;", str)
        gsub(/>/, "&gt;", str)
        return str
    }
    
    BEGIN { section = "General"; is_header_border = 0 }
    
    # Detect sections from headers
    /^-- ==========================+/ {
        is_header_border = 1
        next
    }
    is_header_border {
        if ($0 ~ /^-- [0-9]+\. */) {
            section = $0
            sub(/^-- [0-9]+\. */, "", section)
            sub(/ *$/, "", section)
        }
        is_header_border = 0
    }
    
    # Parse hl.bind lines
    /hl\.bind\(/ {
        line = $0
        
        # 1. Extract shortcut string via robust splitting
        split(line, parts, "\"")
        shortcut = ""
        if (length(parts) >= 2) {
            shortcut = parts[2]
        } else {
            split(line, parts, "'\''")
            if (length(parts) >= 2) {
                shortcut = parts[2]
            }
        }
        
        if (shortcut == "") next
        
        # 2. Extract description from end-of-line comment if present
        desc = ""
        if (line ~ /--/) {
            split(line, comment, "--")
            # Ensure it is not a section divider or state tracking comment
            if (comment[2] !~ /^ *=+/ && comment[2] !~ /^[0-9]+\./ && comment[2] !~ /State tracking/) {
                desc = comment[2]
                gsub(/^ */, "", desc); gsub(/ *$/, "", desc)
            }
        }
        
        # 3. Fallback: Humanize action/command if description is empty
        if (desc == "") {
            if (line ~ /terminal/) desc = "Launch Terminal"
            else if (line ~ /browser/) desc = "Launch Web Browser"
            else if (line ~ /fileFolder/) desc = "Launch File Manager"
            else if (line ~ /codeEditor/) desc = "Launch Code Editor"
            else if (line ~ /launcher\.sh/) desc = "Rofi Application Launcher"
            else if (line ~ /swaync-client/) desc = "Toggle Notifications Panel"
            else if (line ~ /keybinds_hint\.sh/) desc = "Show Keybindings Cheatsheet"
            else if (line ~ /window\.close/) desc = "Close Active Window"
            else if (line ~ /hyprctl kill/) desc = "Kill Window (Force)"
            else if (line ~ /togglefloating|float/) desc = "Toggle Floating State"
            else if (line ~ /fullscreen\(1\)/) desc = "Toggle Maximize State"
            else if (line ~ /fullscreen\(0\)/) desc = "Toggle Fullscreen State"
            else if (line ~ /fullscreen_state/) desc = "Toggle Fake Fullscreen State"
            else if (line ~ /pin/) desc = "Pin Window (Show on all Workspaces)"
            else if (line ~ /togglesplit/) desc = "Toggle Layout Split Direction"
            else if (line ~ /focus.*direction *= *"l"|focus.*direction *= *'\''l'\''/) desc = "Focus Window Left"
            else if (line ~ /focus.*direction *= *"r"|focus.*direction *= *'\''r'\''/) desc = "Focus Window Right"
            else if (line ~ /focus.*direction *= *"u"|focus.*direction *= *'\''u'\''/) desc = "Focus Window Up"
            else if (line ~ /focus.*direction *= *"d"|focus.*direction *= *'\''d'\''/) desc = "Focus Window Down"
            else if (line ~ /move.*direction *= *"l"/) desc = "Move Window Left"
            else if (line ~ /move.*direction *= *"r"/) desc = "Move Window Right"
            else if (line ~ /move.*direction *= *"u"/) desc = "Move Window Up"
            else if (line ~ /move.*direction *= *"d"/) desc = "Move Window Down"
            else if (line ~ /window\.drag/) desc = "Drag Window (Move)"
            else if (line ~ /window\.resize/) desc = "Drag Window (Resize)"
            else if (line ~ /workspace *= *"r\+1"|workspace *= *"\+1"|workspace *= *"e\+1"/) desc = "Switch to Next Workspace"
            else if (line ~ /workspace *= *"r-1"|workspace *= *"-1"|workspace *= *"e-1"/) desc = "Switch to Previous Workspace"
            else if (line ~ /window\.move.*workspace|movetoworkspacesilent/) desc = "Move Window to Workspace"
            else if (line ~ /toggle_special/) desc = "Toggle Special Workspace (Scratchpad)"
            else if (line ~ /lock-session/) desc = "Lock Screen Session"
            else if (line ~ /systemctl suspend|loginctl suspend/) desc = "Suspend System (Sleep)"
            else if (line ~ /systemctl poweroff|loginctl poweroff/) desc = "Power Off / Shutdown System"
            else if (line ~ /hyprshutdown/) desc = "Exit Session / Shutdown Menu"
            else if (line ~ /monitor_menu\.sh/) desc = "Display/Monitor Configuration Menu"
            else if (line ~ /wpctl set-volume.*5%\+/) desc = "Raise Audio Volume"
            else if (line ~ /wpctl set-volume.*5%-/) desc = "Lower Audio Volume"
            else if (line ~ /wpctl set-mute.*SINK/) desc = "Mute/Unmute Audio Volume"
            else if (line ~ /wpctl set-mute.*SOURCE/) desc = "Mute/Unmute Microphone"
            else if (line ~ /brightnessctl.*5%\+/) desc = "Increase Screen Brightness"
            else if (line ~ /brightnessctl.*5%-/) desc = "Decrease Screen Brightness"
            else if (line ~ /playerctl play-pause/) desc = "Media Play / Pause"
            else if (line ~ /playerctl next/) desc = "Media Next Track"
            else if (line ~ /playerctl previous/) desc = "Media Previous Track"
            else if (line ~ /hyprshot -m window/) desc = "Screenshot Active Window"
            else if (line ~ /hyprshot -m output/) desc = "Screenshot Active Monitor"
            else if (line ~ /hyprshot -m region/) desc = "Screenshot Selected Region"
            else if (line ~ /hyprpicker/) desc = "Launch Color Picker (Hex Copy)"
            else if (line ~ /cliphist/) desc = "Launch Clipboard Manager History"
            else if (line ~ /pamixer.*-t/) desc = "Mute/Unmute Mic"
        }
        
        if (desc == "") next
        
        # Importance Weighting
        weight = 99
        if (section ~ /Apps|Launchers/) weight = 10
        else if (section ~ /Window/) weight = 20
        else if (section ~ /Special/) weight = 30
        else if (section ~ /Utilities/) weight = 40
        else if (section ~ /System/) weight = 50
        else if (section ~ /Media/) weight = 60
        else if (section ~ /Workspace/) weight = 70
        
        # --- Humanize Mods & Keys ---
        m = shortcut
        gsub(/SUPER/, "SUPER", m)
        gsub(/SHIFT|Shift/, "Shift", m)
        gsub(/CTRL|Ctrl/, "Ctrl", m)
        gsub(/ALT|Alt/, "Alt", m)
        gsub(/[ \+]/, "", m)
        
        # --- Nerd Font Glyph mapping ---
        glyph = ""
        if (section ~ /Apps|Launchers/) glyph = ""
        else if (section ~ /Window/) glyph = ""
        else if (section ~ /Workspace/) glyph = ""
        else if (section ~ /Special/) glyph = ""
        else if (section ~ /System/) glyph = ""
        else if (section ~ /Media/) glyph = ""
        else if (section ~ /Utilities/) glyph = "🛠"
        
        # Pango Markup
        icon_span = "<span color=\"" blue "\">" glyph "</span>"
        shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(shortcut) "</span>"
        description_span = "<span>" escape(desc) "</span>"
        category_span = "<span color=\"" grey "\" size=\"small\">[" escape(section) "]</span>"
        
        # Format for sorting: Weight|Icon  Shortcut │ Description │ [Section]
        printf "%d|%s  %s │ %s │ %s\n", weight, icon_span, shortcut_span, description_span, category_span
    }
    
    # Programmatically inject workspaces 1 to 10
    END {
        section = "Workspaces Navigation & Management"
        weight = 70
        glyph = ""
        icon_span = "<span color=\"" blue "\">" glyph "</span>"
        category_span = "<span color=\"" grey "\" size=\"small\">[" escape(section) "]</span>"
        
        for (i = 1; i <= 9; i++) {
            # Focus Workspaces
            shortcut = "SUPER + " i
            desc = "Switch to Workspace " i
            shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(shortcut) "</span>"
            description_span = "<span>" escape(desc) "</span>"
            printf "%d|%s  %s │ %s │ %s\n", weight, icon_span, shortcut_span, description_span, category_span
            
            # Move to Workspaces
            shortcut = "SUPER + Shift + " i
            desc = "Move Window to Workspace " i
            shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(shortcut) "</span>"
            description_span = "<span>" escape(desc) "</span>"
            printf "%d|%s  %s │ %s │ %s\n", weight, icon_span, shortcut_span, description_span, category_span
        }
        
        # Workspace 10
        shortcut = "SUPER + 0"
        desc = "Switch to Workspace 10"
        shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(shortcut) "</span>"
        description_span = "<span>" escape(desc) "</span>"
        printf "%d|%s  %s │ %s │ %s\n", weight, icon_span, shortcut_span, description_span, category_span
        
        shortcut = "SUPER + Shift + 0"
        desc = "Move Window to Workspace 10"
        shortcut_span = "<span color=\"" blue "\" weight=\"bold\">" escape(shortcut) "</span>"
        description_span = "<span>" escape(desc) "</span>"
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

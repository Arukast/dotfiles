--------------------------------------------------------------------------------
-- HYPRLAND KEYBINDINGS CONFIGURATION (LUA EDITION)
--------------------------------------------------------------------------------

-- ==========================================
-- 1. Default Applications Variables
-- ==========================================
local terminal   = "kitty"
local browser    = "firefox"
local fileFolder = "dolphin"
local codeEditor = "code"

-- State tracking for per-window fake fullscreen
local fake_fullscreen_windows = {}

-- ==========================================
-- 2. Application Launchers
-- ==========================================
hl.bind("SUPER + T",      hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + W",      hl.dsp.exec_cmd(browser))
hl.bind("SUPER + E",      hl.dsp.exec_cmd(fileFolder))
hl.bind("SUPER + C",      hl.dsp.exec_cmd(codeEditor))
hl.bind("SUPER + SPACE",  hl.dsp.exec_cmd([[~/.config/rofi/launchers/launcher.sh]]))
hl.bind("SUPER + N",      hl.dsp.exec_cmd([[swaync-client -t -sw]]))
hl.bind("SUPER + Slash",  hl.dsp.exec_cmd([[~/.config/hypr/scripts/keybinds_hint.sh]]))

-- ==========================================
-- 3. Window Management
-- ==========================================
hl.bind("SUPER + Q",            hl.dsp.window.close())
hl.bind("ALT + F4",             hl.dsp.window.close())
hl.bind("SUPER+SHIFT+ALT + Q",  hl.dsp.exec_cmd([[hyprctl kill]]))
hl.bind("SUPER+ALT + Space",    hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + G",            hl.dsp.window.fullscreen(1))
hl.bind("SUPER + F",            hl.dsp.window.fullscreen(0))
hl.bind("SUPER+ALT + F",        function()
    local w = hl.get_active_window()
    if w ~= nil then
        local addr = w.address
        if not fake_fullscreen_windows[addr] then
            hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 3 }))
            fake_fullscreen_windows[addr] = true
        else
            hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0 }))
            fake_fullscreen_windows[addr] = nil
        end
    end
end)
hl.bind("SUPER + O",            hl.dsp.window.pin())
hl.bind("SUPER + J",            hl.dsp.layout("togglesplit"))

-- ==========================================
-- 4. Focus & Window Movement (Directions)
-- ==========================================
-- Focus window in direction
hl.bind("SUPER + Left",         hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right",        hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up",           hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down",         hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + BracketLeft",  hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + BracketRight", hl.dsp.focus({ direction = "r" }))

-- Move window in direction
hl.bind("SUPER+SHIFT + Left",   hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER+SHIFT + Right",  hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER+SHIFT + Up",     hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER+SHIFT + Down",   hl.dsp.window.move({ direction = "d" }))

-- ==========================================
-- 5. Mouse Window Controls (Move/Resize)
-- ==========================================
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(),   { mouse = true })

-- ==========================================
-- 6. Workspaces Navigation & Management
-- ==========================================
-- Focus Workspaces (Relative / Dynamic)
hl.bind("CTRL+SUPER + Right",     hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL+SUPER + Left",      hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + Page_Down",      hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + Page_Up",        hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL+SUPER + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL+SUPER + Page_Up",   hl.dsp.focus({ workspace = "r-1" }))

-- Move Window to Relative Workspace (Mouse Wheel / Keyboard)
hl.bind("SUPER+SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER+SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER+ALT + mouse_down",   hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER+ALT + mouse_up",     hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER+ALT + Page_Down",    hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER+ALT + Page_Up",      hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER+SHIFT + Page_Down",  hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER+SHIFT + Page_Up",    hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("CTRL+SUPER+SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("CTRL+SUPER+SHIFT + Left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Scroll through existing workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Programmatic Workspace Keybinds (1 to 10)
for i = 1, 9 do
    hl.bind("SUPER + " .. i,         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind("SUPER + 0",         hl.dsp.focus({ workspace = "10" }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- ==========================================
-- 7. Special Workspaces (Scratchpads)
-- ==========================================
hl.bind("ALT + Tab",         hl.dsp.workspace.toggle_special("special"))
hl.bind("CTRL + ALT + Tab",  hl.dsp.window.move({ workspace = "special", silent = true }))
hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special(""))

-- ==========================================
-- 8. System & Session Controls
-- ==========================================
hl.bind("SUPER + L",                     hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER+SHIFT + L",               hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), { locked = true })
hl.bind("CTRL+SHIFT+ALT+SUPER + Delete", hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"))
hl.bind("SUPER + M",                     hl.dsp.exec_cmd([[command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit]]))
hl.bind("SUPER + P",                     hl.dsp.exec_cmd([[~/.config/hypr/scripts/monitor_menu.sh]]))

-- ==========================================
-- 9. Hardware Controls (Volume / Brightness)
-- ==========================================
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd([[wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+]]), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd([[wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-]]), { repeating = true, locked = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle]]), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle]]), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd([[brightnessctl -e4 -n2 set 5%+]]), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd([[brightnessctl -e4 -n2 set 5%-]]), { repeating = true, locked = true })

-- ==========================================
-- 10. Media Controls (playerctl)
-- ==========================================
hl.bind("SUPER+SHIFT + P", hl.dsp.exec_cmd([[playerctl play-pause]]), { locked = true })
hl.bind("SUPER+SHIFT + N", hl.dsp.exec_cmd([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]), { locked = true })
hl.bind("SUPER+SHIFT + B", hl.dsp.exec_cmd([[playerctl previous]]), { locked = true })
hl.bind("XF86AudioPlay",   hl.dsp.exec_cmd([[playerctl play-pause]]), { locked = true })
hl.bind("XF86AudioPause",  hl.dsp.exec_cmd([[playerctl play-pause]]), { locked = true })
hl.bind("XF86AudioNext",   hl.dsp.exec_cmd([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]), { locked = true })
hl.bind("XF86AudioPrev",   hl.dsp.exec_cmd([[playerctl previous]]), { locked = true })

-- ==========================================
-- 11. Utilities & Screenshot Tools
-- ==========================================
hl.bind("SUPER + PRINT",     hl.dsp.exec_cmd([[hyprshot -m window]]))
hl.bind("PRINT",             hl.dsp.exec_cmd([[hyprshot -m output]]))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[hyprshot -m region]]))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd([[hyprpicker -a]]))
hl.bind("SUPER + V",         hl.dsp.exec_cmd([[cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy]]))
hl.bind("CTRL + SHIFT + grave", hl.dsp.exec_cmd([[pamixer --default-source -t]]))

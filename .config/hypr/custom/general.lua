local function setup_monitors()
    hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = "1" })
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
    
    local f = io.open(os.getenv("HOME") .. "/.config/hypr/monitors.conf", "r")
    if f then
        for line in f:lines() do
            local match = line:match("^monitor=(.*)")
            if match then
                local parts = {}
                for part in string.gmatch(match, "([^,]+)") do
                    table.insert(parts, part:match("^%s*(.-)%s*$"))
                end
                if #parts >= 4 then
                    hl.monitor({
                        output = parts[1],
                        mode = parts[2],
                        position = parts[3],
                        scale = parts[4]
                    })
                end
            end
        end
        f:close()
    end
end
setup_monitors()

local function setup_workspaces()
    local static_workspaces = {
        "1, monitor:eDP-1, default:true",
        "2, monitor:eDP-1",
        "3, monitor:eDP-1",
        "4, monitor:eDP-1",
        "5, monitor:HDMI-A-1, default:true",
        "6, monitor:HDMI-A-1",
        "7, monitor:HDMI-A-1",
        "8, monitor:DP-2, default:true",
        "9, monitor:DP-2",
        "10, monitor:DP-2"
    }
    
    local function apply_ws(ws_str)
        local parts = {}
        for part in string.gmatch(ws_str, "([^,]+)") do
            table.insert(parts, part:match("^%s*(.-)%s*$"))
        end
        if #parts > 0 then
            local rule = { workspace = parts[1] }
            for i = 2, #parts do
                if parts[i]:match("monitor:(.*)") then
                    rule.monitor = parts[i]:match("monitor:(.*)")
                elseif parts[i]:match("default:(.*)") then
                    rule.default = (parts[i]:match("default:(.*)") == "true")
                else
                    -- For any other things like gapsout:20, etc.
                    local k, v = parts[i]:match("([^:]+):(.*)")
                    if k and v then
                        rule[k] = v
                    end
                end
            end
            hl.workspace_rule(rule)
        end
    end
    
    for _, ws in ipairs(static_workspaces) do
        apply_ws(ws)
    end
    
    local f = io.open(os.getenv("HOME") .. "/.config/hypr/workspaces.conf", "r")
    if f then
        for line in f:lines() do
            local match = line:match("^workspace=(.*)")
            if match then apply_ws(match) end
        end
        f:close()
    end
end
setup_workspaces()

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 5,
        gaps_workspaces = 50,
        border_size = 1,
        ["col.active_border"] = "rgba(0DB7D455)",
        ["col.inactive_border"] = "rgba(31313600)",
        resize_on_border = true,
        no_focus_fallback = true,
        allow_tearing = true,
        snap = {
            enabled = true,
            window_gap = 4,
            monitor_gap = 5,
            respect_gaps = true
        }
    },
    decoration = {
        rounding = 18,
        rounding_power = 2.4,
        dim_inactive = true,
        dim_strength = 0.05,
        dim_special = 0.07,
        shadow = {
            enabled = true,
            range = 6,
            offset = "0 4",
            render_power = 1,
            color = "rgba(00000027)"
        },
        blur = {
            enabled = true,
            xray = true,
            special = false,
            new_optimizations = true,
            size = 5,
            passes = 1,
            brightness = 1,
            noise = 0.05,
            contrast = 0.89,
            vibrancy = 0.5,
            vibrancy_darkness = 0.5,
            popups = false,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.8
        }
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = true,
        swallow_regex = "(foot|kitty|allacritty|Alacritty)",
        on_focus_under_fullscreen = 2,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        initial_workspace_tracking = false,
        focus_on_activate = true
    },
    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = true
    },
    cursor = {
        no_hardware_cursors = true,
        zoom_factor = 1,
        zoom_rigid = false,
        hotspot_padding = 1
    },
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,

        follow_mouse = 1,
        off_window_axis_events = 2,

        accel_profile = "flat",

        sensitivity = 0.8, -- Adjust from -1.0 to 1.0. Lower/negative values make the cursor slower.


        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.7
        }
    },
    gesture = {
        "3, swipe, move",
        "3, pinch, float",
        "4, horizontal, workspace",
        "4, up, dispatcher, global, quickshell:overviewWorkspacesToggle",
        "4, down, dispatcher, global, quickshell:overviewWorkspacesClose"
    },
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true
    }
})

-- =============================================================================
-- 3. Animation Curves (Snappy & Fast)
-- =============================================================================
hl.curve("expressiveFastSpatial",    { type = "bezier", points = { {0.42, 1.67}, {0.21, 0.90} } })
hl.curve("expressiveSlowSpatial",    { type = "bezier", points = { {0.39, 1.29}, {0.35, 0.98} } })
hl.curve("expressiveDefaultSpatial", { type = "bezier", points = { {0.38, 1.21}, {0.22, 1.00} } })
hl.curve("emphasizedDecel",          { type = "bezier", points = { {0.05, 0.7},  {0.1, 1} } })
hl.curve("emphasizedAccel",          { type = "bezier", points = { {0.3, 0},    {0.8, 0.15} } })
hl.curve("standardDecel",            { type = "bezier", points = { {0, 0},      {0, 1} } })
hl.curve("menu_decel",               { type = "bezier", points = { {0.1, 1},    {0, 1} } })
hl.curve("menu_accel",               { type = "bezier", points = { {0.52, 0.03}, {0.72, 0.08} } })
hl.curve("stall",                    { type = "bezier", points = { {1, -0.1},   {0.7, 0.85} } })

-- bezIn and bezOut curves for focus animations
hl.curve("bezIn",                    { type = "bezier", points = { {0.5, 0.0},  {1.0, 0.5} } })
hl.curve("bezOut",                   { type = "bezier", points = { {0.0, 0.5},  {0.5, 1.0} } })

-- =============================================================================
-- 4. Desktop Animation Tree Configuration (Snappy & Fast)
-- =============================================================================
hl.animation({ leaf = "windowsIn",          enabled = true, speed = 2.5, bezier = "menu_decel", style = "popin 80%" })
hl.animation({ leaf = "fadeIn",             enabled = true, speed = 2.5, bezier = "menu_decel" })
hl.animation({ leaf = "windowsOut",         enabled = true, speed = 2.0, bezier = "menu_accel", style = "popin 90%" })
hl.animation({ leaf = "fadeOut",            enabled = true, speed = 2.0, bezier = "menu_accel" })
hl.animation({ leaf = "windowsMove",        enabled = true, speed = 2.8, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "border",             enabled = true, speed = 2.5, bezier = "menu_decel" })
hl.animation({ leaf = "layersIn",           enabled = true, speed = 2.2, bezier = "menu_decel", style = "popin 93%" })
hl.animation({ leaf = "layersOut",          enabled = true, speed = 1.8, bezier = "menu_accel", style = "popin 94%" })
hl.animation({ leaf = "fadeLayersIn",       enabled = true, speed = 1.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut",      enabled = true, speed = 1.8, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces",         enabled = true, speed = 3.5, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3.0, bezier = "menu_decel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2.5, bezier = "menu_accel", style = "slidevert" })

-- =============================================================================
-- 5. Plugins Configuration (Snappy Focus Animations)
-- =============================================================================
local is_verifying = false
local f = io.open("/proc/self/cmdline", "r")
if f then
    local cmdline = f:read("*a")
    f:close()
    if cmdline and cmdline:find("verify%-config") then
        is_verifying = true
    end
end

if not is_verifying then
    local handle = io.popen("hyprctl plugin list 2>/dev/null")
    local loaded_plugins = handle and handle:read("*a") or ""
    if handle then handle:close() end

    if loaded_plugins:find("hyprfocus") then
        pcall(hl.config, {
            plugin = {
                hyprfocus = {
                    keyboard_focus_animation = "shrink",
                    mouse_focus_animation = "flash",
                    bezier = {
                        "bezIn, 0.5, 0.0, 1.0, 0.5",
                        "bezOut, 0.0, 0.5, 0.5, 1.0"
                    },
                    flash = {
                        flash_opacity = 0.85,
                        in_bezier = "bezIn",
                        in_speed = 2.0,
                        out_bezier = "bezOut",
                        out_speed = 5.5
                    },
                    shrink = {
                        shrink_percentage = 0.96,
                        in_bezier = "bezIn",
                        in_speed = 2.0,
                        out_bezier = "bezOut",
                        out_speed = 5.5
                    }
                }
            }
        })
    end
end

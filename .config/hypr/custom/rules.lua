--------------------------------------------------------------------------------
-- HYPRLAND WINDOW & LAYER RULES CONFIGURATION (LUA EDITION)
-- Consolidated to remove extreme repetitions and grouped for maximum readability
--------------------------------------------------------------------------------

-- =============================================================================
-- Helper Functions (Ensures 100% C++ compatibility by registering 1 action/call)
-- =============================================================================
local function add_window_rule(match_tbl, rules_tbl)
    for k, v in pairs(rules_tbl) do
        hl.window_rule({
            match = match_tbl,
            [k] = v
        })
    end
end

local function add_layer_rule(match_tbl, rules_tbl)
    for k, v in pairs(rules_tbl) do
        hl.layer_rule({
            match = match_tbl,
            [k] = v
        })
    end
end

-- =============================================================================
-- 1. Global / Default Window Rules
-- =============================================================================
add_window_rule({ class = "^.*$" }, {
    opacity = "0.99 override 0.99 override",
    no_blur = true,
})

hl.window_rule({
    match = { xwayland = "1" },
    no_blur = true,
})

hl.window_rule({
    match = { class = "^()$", title = "^()$" },
    no_blur = true,
})

-- =============================================================================
-- 2. Floating Dialogs & File Pickers (Center + Float)
-- =============================================================================
local dialog_titles = {
    "^(Open File).*$",
    "^(Select a File).*$",
    "^(Open Folder).*$",
    "^(Save As).*$",
    "^(Library).*$",
    "^(File Upload).*$",
    "^(.*)(wants to save)$",
    "^(.*)(wants to open)$"
}
for _, title_pat in ipairs(dialog_titles) do
    add_window_rule({ title = title_pat }, {
        center = true,
        float = true,
    })
end

-- Choose Wallpaper Dialog
add_window_rule({ title = "^(Choose wallpaper).*$" }, {
    float = true,
    center = true,
    size = "(monitor_w*.60) (monitor_h*.65)",
})

-- =============================================================================
-- 3. App-Specific Window Rules
-- =============================================================================

-- System Tools (Volume, Network, Bluetooth)
add_window_rule({ class = "^(pavucontrol)$" }, {
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

add_window_rule({ class = "^(org.pulseaudio.pavucontrol)$" }, {
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

add_window_rule({ class = "^(nm-connection-editor)$" }, {
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = { class = [[^(blueberry\.py)$]] },
    float = true,
})

hl.window_rule({
    match = { class = "^(guifetch)$" },
    float = true,
})

-- KDE & Plasma components
add_window_rule({ class = "org.freedesktop.impl.portal.desktop.kde" }, {
    float = true,
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    match = { class = "^.*plasmawindowed.*$" },
    float = true,
})

hl.window_rule({
    match = { class = "^kcm_.*$" },
    float = true,
})

hl.window_rule({
    match = { class = "^.*bluedevilwizard$" },
    float = true,
})

add_window_rule({ class = "^(plasma-changeicons)$" }, {
    float = true,
    no_initial_focus = true,
    move = "999999 999999",
})

hl.window_rule({
    match = { title = "^(Copying — Dolphin)$" },
    move = "40 80",
})

-- Miscellaneous Apps
add_window_rule({ class = "^(Zotero)$" }, {
    float = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = { title = "^.*Welcome$" },
    float = true,
})

hl.window_rule({
    match = { title = "^(illogical-impulse Settings)$" },
    float = true,
})

hl.window_rule({
    match = { title = "^.*Shell conflicts.*$" },
    float = true,
})

hl.window_rule({
    match = { class = [[^dev\.warp\.Warp$]] },
    tile = true,
})

-- Picture-in-Picture
add_window_rule({ title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]] }, {
    float = true,
    keep_aspect_ratio = true,
    pin = true,
    move = "(monitor_w*.73) (monitor_h*.72)",
    size = "(monitor_w*.25) (monitor_h*.25)",
})

-- =============================================================================
-- 4. Game Rules (Immediate rendering / Tearing support)
-- =============================================================================
local immediate_rules = {
    { title = [[^.*\.exe$]] },
    { title = "^.*minecraft.*$" },
    { class = "^(steam_app).*" }
}
for _, m in ipairs(immediate_rules) do
    hl.window_rule({
        match = m,
        immediate = true,
    })
end

-- =============================================================================
-- 5. Specialized Window Rules
-- =============================================================================
hl.window_rule({
    match = {
        class = "^jetbrains-.*$",
        float = "1",
        title = [[^$|^\s$|^win\d+$]]
    },
    no_initial_focus = true,
})

hl.window_rule({
    match = { float = "0" },
    no_shadow = true,
})

-- =============================================================================
-- 6. Workspace Rules
-- =============================================================================
hl.workspace_rule({
    workspace = "special:special",
    gaps_out = "20",
})

-- =============================================================================
-- 7. Layer Rules
-- =============================================================================
-- Global fallback xray
hl.layer_rule({
    match = { namespace = "^.*$" },
    xray = true,
})

-- Waybar overlay
add_layer_rule({ namespace = "waybar" }, {
    blur = true,
    ignore_alpha = "0.1",
    xray = false,
})

-- No-animation interfaces
local no_anim_namespaces = {
    "walker",
    "selection",
    "overview",
    "anyrun",
    "indicator.*",
    "osk",
    "hyprpicker",
    "noanim",
    "$menu"
}
for _, ns in ipairs(no_anim_namespaces) do
    hl.layer_rule({
        match = { namespace = ns },
        no_anim = true,
    })
end

-- GTK Shells
add_layer_rule({ namespace = "gtk-layer-shell" }, {
    blur = true,
    ignore_alpha = "0",
})

-- Rofi Launcher
add_layer_rule({ namespace = "launcher" }, {
    blur = true,
    ignore_alpha = "0.5",
})

-- SwayNC Notifications
hl.layer_rule({
    match = { namespace = "notifications" },
    ignore_alpha = "0.69",
})

add_layer_rule({ namespace = "swaync-control-center" }, {
    blur = true,
    ignore_alpha = "0.5",
    xray = false,
})

add_layer_rule({ namespace = "swaync-notification-window" }, {
    blur = true,
    ignore_alpha = "0.5",
    xray = false,
})

-- WLogout Dialog
hl.layer_rule({
    match = { namespace = "logout_dialog # wlogout" },
    blur = true,
})

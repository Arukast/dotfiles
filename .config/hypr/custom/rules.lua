hl.window_rule({
    match = {
        class = "^.*$",
    },
    opacity = "0.99 override 0.99 override",
})

hl.window_rule({
    match = {
        xwayland = "1",
    },
    no_blur = true,
})

hl.window_rule({
    match = {
        class = "^()$",
        title = "^()$",
    },
    no_blur = true,
})

hl.window_rule({
    match = {
        class = "^.*$",
    },
    no_blur = true,
})

hl.window_rule({
    match = {
        title = "^(Open File).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Open File).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Select a File).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Select a File).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Choose wallpaper).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Choose wallpaper).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Choose wallpaper).*$",
    },
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    match = {
        title = "^(Open Folder).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Open Folder).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Save As).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Save As).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Library).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Library).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(File Upload).*$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(File Upload).*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(.*)(wants to save)$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(.*)(wants to save)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(.*)(wants to open)$",
    },
    center = true,
})

hl.window_rule({
    match = {
        title = "^(.*)(wants to open)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = [[^(blueberry\.py)$]],
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(guifetch)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    center = true,
})

hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    center = true,
})

hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    center = true,
})

hl.window_rule({
    match = {
        class = "^.*plasmawindowed.*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^kcm_.*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^.*bluedevilwizard$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^.*Welcome$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(illogical-impulse Settings)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^.*Shell conflicts.*$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "org.freedesktop.impl.portal.desktop.kde",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "org.freedesktop.impl.portal.desktop.kde",
    },
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    match = {
        class = "^(Zotero)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(Zotero)$",
    },
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = {
        class = "^(plasma-changeicons)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(plasma-changeicons)$",
    },
    no_initial_focus = true,
})

hl.window_rule({
    match = {
        class = "^(plasma-changeicons)$",
    },
    move = "999999 999999",
})

hl.window_rule({
    match = {
        title = "^(Copying — Dolphin)$",
    },
    move = "40 80",
})

hl.window_rule({
    match = {
        class = [[^dev\.warp\.Warp$]],
    },
    tile = true,
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    float = true,
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    keep_aspect_ratio = true,
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    move = "(monitor_w*.73) (monitor_h*.72)",
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    size = "(monitor_w*.25) (monitor_h*.25)",
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    float = true,
})

hl.window_rule({
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture).*$]],
    },
    pin = true,
})

hl.window_rule({
    match = {
        title = [[^.*\.exe$]],
    },
    immediate = true,
})

hl.window_rule({
    match = {
        title = "^.*minecraft.*$",
    },
    immediate = true,
})

hl.window_rule({
    match = {
        class = "^(steam_app).*",
    },
    immediate = true,
})

hl.window_rule({
    match = {
        class = "^jetbrains-.*$",
        float = "1",
        title = [[^$|^\s$|^win\d+$]],
    },
    no_initial_focus = true,
})

hl.window_rule({
    match = {
        float = "0",
    },
    no_shadow = true,
})

hl.workspace_rule({
    workspace = "special:special",
    gaps_out = "20",
})

hl.layer_rule({
    match = {
        namespace = "^.*$",
    },
    xray = true,
})

hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    ignore_alpha = "0.1",
})

hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    xray = false,
})

hl.layer_rule({
    match = {
        namespace = "walker",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "selection",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "overview",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "anyrun",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "indicator.*",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "osk",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "hyprpicker",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "noanim",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "gtk-layer-shell",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "gtk-layer-shell",
    },
    ignore_alpha = "0",
})

hl.layer_rule({
    match = {
        namespace = "launcher",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "launcher",
    },
    ignore_alpha = "0.5",
})

hl.layer_rule({
    match = {
        namespace = "notifications",
    },
    ignore_alpha = "0.69",
})

hl.layer_rule({
    match = {
        namespace = "swaync-control-center",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "swaync-control-center",
    },
    ignore_alpha = "0.5",
})

hl.layer_rule({
    match = {
        namespace = "swaync-control-center",
    },
    xray = false,
})

hl.layer_rule({
    match = {
        namespace = "swaync-notification-window",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "swaync-notification-window",
    },
    ignore_alpha = "0.5",
})

hl.layer_rule({
    match = {
        namespace = "swaync-notification-window",
    },
    xray = false,
})

hl.layer_rule({
    match = {
        namespace = "logout_dialog # wlogout",
    },
    blur = true,
})

hl.layer_rule({
    match = {
        namespace = "$menu",
    },
    no_anim = true,
})

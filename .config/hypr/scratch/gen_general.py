import sys
import re

with open("custom/general.lua", "r") as f:
    content = f.read()

# The original general.lua builds a table and passes it to hl.config()
# We just want to replace the top part that parses monitors and workspaces.
# The table starts at `hl.config({`

parts = content.split("hl.config({", 1)
if len(parts) == 2:
    config_body = "hl.config({\n" + parts[1]
    
    # Let's remove monitor = monitors, and workspace = workspaces, from config_body
    config_body = re.sub(r'^\s*monitor\s*=\s*monitors,\s*\n', '', config_body, flags=re.MULTILINE)
    config_body = re.sub(r'^\s*workspace\s*=\s*workspaces,\s*\n', '', config_body, flags=re.MULTILINE)

    new_lua = """local function setup_monitors()
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

""" + config_body
    
    with open("custom/general.lua", "w") as f:
        f.write(new_lua)

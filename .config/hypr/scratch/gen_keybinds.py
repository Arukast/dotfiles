import sys
import re

with open("custom/keybinds.conf", "r") as f:
    lines = f.readlines()

out = []
out.append('local terminal = "kitty"')
out.append('local browser = "firefox"')
out.append('local fileManager = "dolphin"')
out.append('local codeEditor = "code"')
out.append('')

for line in lines:
    line = line.strip()
    if not line or line.startswith('#'): continue
    
    if line.startswith('bind'):
        parts = line.split('=', 1)
        if len(parts) != 2: continue
        bind_type = parts[0].strip()
        bind_args_str = parts[1].split('#')[0].strip()
        
        args = [arg.strip() for arg in bind_args_str.split(',')]
        if len(args) < 3: continue
        
        mods = args[0]
        mods = mods.upper()  # Uppercase all mods (CTRL, SHIFT, ALT)
        mods = mods.replace('$MAINMOD', 'SUPER')
        mods = mods.replace(' ', ' + ')
        # fix multiple pluses
        mods = mods.replace('++', '+')
        if 'SHIFT' in mods and '+SHIFT' not in mods and 'SHIFT+' not in mods and ' + SHIFT' not in mods:
            mods = mods.replace('SHIFT', '+ SHIFT')
        if 'ALT' in mods and '+ALT' not in mods and 'ALT+' not in mods and ' + ALT' not in mods:
            mods = mods.replace('ALT', '+ ALT')
        if 'CTRL' in mods and '+CTRL' not in mods and 'CTRL+' not in mods and ' + CTRL' not in mods:
            mods = mods.replace('CTRL', '+ CTRL')
            
        key = args[1]
        
        # Combine mods and key
        keys_str = f"{mods} + {key}" if mods else key
        # clean up multiple + signs
        keys_str = re.sub(r'\+\s*\+', '+', keys_str)
        # trim + at start
        keys_str = keys_str.lstrip(' +')
        
        dispatcher_name = args[2]
        dispatcher_args = ','.join(args[3:]).strip() if len(args) > 3 else ""
        
        flags = []
        if bind_type == 'bindm':
            flags.append('mouse = true')
        elif bind_type == 'bindd':
            pass
        elif bind_type == 'bindl':
            flags.append('locked = true')
        elif bind_type == 'bindel':
            flags.append('repeating = true')
            flags.append('locked = true')
        elif bind_type == 'bindld':
            flags.append('locked = true')
            
        flags_str = ", ".join([f"{f}" for f in flags])
        if flags_str:
            flags_str = f", {{ {flags_str} }}"
        else:
            flags_str = ""
            
        dsp = f'hl.dsp.exec_cmd("hyprctl dispatch {dispatcher_name} {dispatcher_args}")'
        if dispatcher_name == 'exec':
            cmd = dispatcher_args
            cmd = cmd.replace('$terminal', '" .. terminal .. "')
            cmd = cmd.replace('$browser', '" .. browser .. "')
            cmd = cmd.replace('$fileManager', '" .. fileManager .. "')
            cmd = cmd.replace('$codeEditor', '" .. codeEditor .. "')
            if '" .. ' in cmd:
                dsp = f'hl.dsp.exec_cmd("{cmd}")'
            else:
                dsp = f'hl.dsp.exec_cmd([[{cmd}]])'
        elif dispatcher_name == 'workspace':
            if dispatcher_args == 'e+1' or dispatcher_args == 'e-1':
                dsp = f'hl.dsp.exec_cmd("hyprctl dispatch workspace {dispatcher_args}")'
            else:
                dsp = f'hl.dsp.focus({{ workspace = "{dispatcher_args}" }})'
        elif dispatcher_name == 'movetoworkspace':
            dsp = f'hl.dsp.window.move({{ workspace = "{dispatcher_args}" }})'
        elif dispatcher_name == 'movefocus':
            dsp = f'hl.dsp.focus({{ direction = "{dispatcher_args}" }})'
        elif dispatcher_name == 'movewindow':
            if bind_type == 'bindm':
                dsp = f'hl.dsp.window.drag()'
            else:
                dsp = f'hl.dsp.window.move({{ direction = "{dispatcher_args}" }})'
        elif dispatcher_name == 'killactive':
            dsp = f'hl.dsp.window.close()'
        elif dispatcher_name == 'resizewindow':
            dsp = f'hl.dsp.window.resize()'
        elif dispatcher_name == 'togglefloating':
            dsp = f'hl.dsp.window.float({{ action = "toggle" }})'
        elif dispatcher_name == 'togglespecialworkspace':
            dsp = f'hl.dsp.workspace.toggle_special("{dispatcher_args}")'
        
        out.append(f'hl.bind("{keys_str}", {dsp}{flags_str})')

out.append('''
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))
''')

with open("custom/keybinds.lua", "w") as f:
    f.write('\n'.join(out))

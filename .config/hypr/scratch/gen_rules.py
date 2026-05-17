import sys
import re

with open("custom/rules.conf", "r") as f:
    lines = f.readlines()

out = []

for line in lines:
    line = line.strip()
    if not line or line.startswith('#'):
        continue

    if line.startswith('windowrule') or line.startswith('layerrule'):
        is_window = line.startswith('windowrule')
        parts = line.split('=', 1)
        if len(parts) != 2:
            continue
        
        args_str = parts[1].strip()
        args = [arg.strip() for arg in args_str.split(',')]
        
        matches = []
        rules = []
        
        for arg in args:
            if arg.startswith('match:'):
                match_val = arg[6:].strip()
                if ' ' in match_val:
                    k, v = match_val.split(' ', 1)
                    matches.append((k.strip(), v.strip()))
                else:
                    pass
            elif arg.startswith('opacity'):
                rules.append(('opacity', arg[len('opacity'):].strip()))
            elif arg.startswith('size'):
                rules.append(('size', arg[len('size'):].strip()))
            elif arg.startswith('move'):
                rules.append(('move', arg[len('move'):].strip()))
            elif arg.startswith('ignore_alpha'):
                rules.append(('ignore_alpha', arg[len('ignore_alpha'):].strip()))
            elif arg.startswith('workspace'):
                rules.append(('workspace', arg[len('workspace'):].strip()))
            else:
                if arg.endswith(' on'):
                    rules.append((arg[:-3].strip(), 'true'))
                elif arg.endswith(' off'):
                    rules.append((arg[:-4].strip(), 'false'))
                else:
                    parts_space = arg.split(' ', 1)
                    if len(parts_space) == 2:
                        rules.append((parts_space[0].strip(), parts_space[1].strip()))
                    else:
                        rules.append((arg, 'true'))
        
        if is_window:
            out.append('hl.window_rule({')
        else:
            out.append('hl.layer_rule({')
            
        if matches:
            out.append('    match = {')
            for k, v in matches:
                if '\\' in v or '"' in v or "'" in v:
                    out.append(f'        {k} = [[{v}]],')
                else:
                    out.append(f'        {k} = "{v}",')
            out.append('    },')
            
        for k, v in rules:
            # Fix 'float' explicitly
            if k == 'float' and v not in ['true', 'false']:
                # The old conf had match:float 1, maybe it got parsed as float = 1
                if v == '1': v = 'true'
                elif v == '0': v = 'false'
                else: v = 'true'
            
            if v in ['true', 'false']:
                out.append(f'    {k} = {v},')
            else:
                out.append(f'    {k} = "{v}",')
        out.append('})')
        out.append('')
    elif line.startswith('workspace'):
        parts = line.split('=', 1)
        if len(parts) != 2: continue
        args_str = parts[1].strip()
        args = [a.strip() for a in args_str.split(',')]
        if len(args) >= 2:
            ws = args[0]
            rules = args[1:]
            out.append('hl.workspace_rule({')
            out.append(f'    workspace = "{ws}",')
            for r in rules:
                if ':' in r:
                    k, v = r.split(':', 1)
                    if k == 'gapsout': k = 'gaps_out'
                    if k == 'gapsin': k = 'gaps_in'
                    out.append(f'    {k} = "{v}",')
                elif r.endswith(' on'):
                    out.append(f'    {r[:-3]} = true,')
            out.append('})')
            out.append('')

with open("custom/rules.lua", "w") as f:
    f.write('\n'.join(out))

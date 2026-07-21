# ==============================================================================
# Fish Shell Configuration (~/.config/fish/config.fish)
# ==============================================================================

# --- Environment Variables & PATH ---
set -gx CCACHE_DIR "$HOME/.ccache"
set -gx CCACHE_MAXSIZE 5G

fish_add_path "$HOME/.spicetify"
fish_add_path "$HOME/.local/bin"

# --- Interactive Session Configuration ---
if status is-interactive

    # Disable default welcome greeting
    set -g fish_greeting

    # Initialize Starship prompt if installed
    if type -q starship
        starship init fish | source
    end

    # Quickshell color sequences
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # --- Aliases & Overrides ---
    alias pamcan 'pacman'
    alias q 'qs -c ii'
    alias da 'date "+%A, %B %d, %Y [%T]"'
    alias hist 'history | grep'
    alias openports 'ss --all --numeric --processes --ipv4 --ipv6'
    alias pgg 'ps -Af | grep'
    alias .. 'cd ..'
    alias cd.. 'cd ..'

    # Error-tolerant shell exit aliases
    alias :q 'exit'
    alias :Q 'exit'
    alias :x 'exit'

    # File Listing (Use eza if available, fallback to ls)
    if type -q eza
        alias ls 'eza --icons'
        alias ll 'eza -l --icons'
        alias la 'eza -la --icons'
        alias lt 'eza --tree --icons'
        alias lm 'eza -la --icons | less'
    else
        alias ls 'ls -hF --color=auto'
        alias ll 'ls -l -hF --color=auto'
        alias la 'ls -la -hF --color=auto'
        alias lr 'ls -R'
        alias lx 'll -BX'
        alias lz 'll -rS'
        alias lt 'll -rt'
        alias lm 'la | less'
    end

    # Colordiff integration
    if type -q colordiff
        alias diff 'colordiff'
    end

    # System & Navigation Defaults
    alias grep 'grep --color=auto'
    alias more 'less'
    alias df 'df -h'
    alias du 'du -c -h'
    alias du1 'du --max-depth=1'
    alias mkdir 'mkdir -p -v'
    alias nano 'nano -w'
    alias ping 'ping -c 5'
    alias dmesg 'dmesg -HL'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias cls 'printf "\033c"'

    # Safety Features
    alias cp 'cp -i'
    alias mv 'mv -i'
    alias rm 'rm -Iv --one-file-system'
    alias ln 'ln -i'
    alias chown 'chown --preserve-root'
    alias chmod 'chmod --preserve-root'
    alias chgrp 'chgrp --preserve-root'

    # System Maintenance & Disk Monitoring
    alias checkmount 'mount | grep -E "sd[a-z][0-9]"'
    alias checktrim 'lsblk -d -o NAME,SIZE,MODEL,DISC-GRAN,DISC-MAX'
    alias dotrim 'sudo fstrim -av'

    # Privileged Access (Non-root user)
    if test (id -u) -ne 0
        alias scat 'sudo cat'
        alias svim 'sudoedit'
        alias root 'sudo -i'
        alias reboot 'sudo systemctl reboot'
        alias poweroff 'sudo systemctl poweroff'
        alias netctl 'sudo netctl'
    end

    # Fix unknown terminal issues (e.g. xterm-kitty on remote SSH)
    alias fix-kitty 'set -gx TERM xterm-256color'

end

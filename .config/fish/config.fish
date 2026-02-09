function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'

    # --- Modified commands ---
    # Cek apakah colordiff terinstall
    if type -q colordiff
        alias diff 'colordiff'
    end

    alias grep 'grep --color=auto'
    alias more 'less'
    alias df 'df -h'
    alias du 'du -c -h'
    alias mkdir 'mkdir -p -v'
    alias nano 'nano -w'
    alias ping 'ping -c 5'
    
    # dmesg sering butuh sudo, kita set aman
    alias dmesg 'dmesg -HL'

    # --- New commands ---
    alias da 'date "+%A, %B %d, %Y [%T]"'
    alias du1 'du --max-depth=1'
    alias hist 'history | grep'
    alias openports 'ss --all --numeric --processes --ipv4 --ipv6'
    alias pgg 'ps -Af | grep'
    alias .. 'cd ..'

    # --- Privileged access ---
    # Logika "if UID != 0" versi Fish
    if test (id -u) -ne 0
        alias scat 'sudo cat'
        alias svim 'sudoedit'
        alias root 'sudo -i'
        alias reboot 'sudo systemctl reboot'
        alias poweroff 'sudo systemctl poweroff'
        alias update 'sudo pacman -Syu'   # Sudah diperbaiki (Syu)
        alias netctl 'sudo netctl'
        
        # Catatan: Trik "alias sudo='sudo '" ala Bash tidak jalan di Fish.
        # Fish punya cara parsing berbeda, jadi sudo ll (alias) mungkin tidak jalan 
        # kecuali Anda membuat fungsi wrapper, tapi sudo ls -l tetap jalan.
    end

    # --- ls aliases ---
    alias ls 'ls -hF --color=auto'
    alias lr 'ls -R'
    alias ll 'ls -l'
    alias la 'll -A'
    alias lx 'll -BX'
    alias lz 'll -rS'
    alias lt 'll -rt'
    alias lm 'la | more'

    # --- Safety features ---
    alias cp 'cp -i'
    alias mv 'mv -i'
    
    # Versi RM aman pilihan Anda
    alias rm 'rm -Iv --one-file-system'
    
    alias ln 'ln -i'
    alias chown 'chown --preserve-root'
    alias chmod 'chmod --preserve-root'
    alias chgrp 'chgrp --preserve-root'
    
    # Fish menggunakan printf agar lebih konsisten daripada echo -ne
    alias cls 'printf "\033c"'

    # --- Make Shell error tolerant ---
    alias :q 'exit'
    alias :Q 'exit'
    alias :x 'exit'
    alias cd.. 'cd ..'
	
end

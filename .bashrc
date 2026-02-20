#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


## Modified commands
alias diff='colordiff'              # requires colordiff package
alias grep='grep --color=auto'
alias more='less'
alias df='df -h'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias nano='nano -w'
alias ping='ping -c 5'
alias dmesg='dmesg -HL'

## New commands
alias da='date "+%A, %B %d, %Y [%T]"'
alias du1='du --max-depth=1'
alias hist='history | grep'         # requires an argument
alias openports='ss --all --numeric --processes --ipv4 --ipv6'
alias pgg='ps -Af | grep'           # requires an argument
alias ..='cd ..'

# Privileged access
if (( UID != 0 )); then
    alias sudo='sudo '
    alias scat='sudo cat'
    alias svim='sudoedit'
    alias root='sudo -i'
    alias reboot='sudo systemctl reboot'
    alias poweroff='sudo systemctl poweroff'
    alias update='printf "\nUpdating pacman packages...\n" && sudo pacman -Syu && printf "\nUpdating AUR packages...\n" && yay -Syu && printf "\nUpdating Flatpak packages...\n" && flatpak update'
    alias netctl='sudo netctl'
fi

## ls
alias ls='ls -hF --color=auto'
alias lr='ls -R'                    # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -BX'                   # sort by extension
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias lm='la | more'

## Safety features
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -Iv --one-file-system'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)

## Make Bash error tolerant
alias :q=' exit'
alias :Q=' exit'
alias :x=' exit'
alias cd..='cd ..'

PS1='[\u@\h \W]\$ '

alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Fungsi membuka VS Code dengan konteks Dotfiles
function code-dot() {
    # Jika ada argumen folder (misal: code-dot .config/nvim), pakai itu.
    # Jika kosong, otomatis buka folder saat ini (.).
    TARGET="${1:-.}"
    GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME code "$TARGET"
}

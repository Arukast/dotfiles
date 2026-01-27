#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Fungsi membuka VS Code dengan konteks Dotfiles
function code-dot() {
    # Jika ada argumen folder (misal: code-dot .config/nvim), pakai itu.
    # Jika kosong, otomatis buka folder saat ini (.).
    TARGET="${1:-.}"
    GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME code "$TARGET"
}

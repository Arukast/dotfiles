function config --wraps=git --description "Manage dotfiles bare git repository"
    /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end

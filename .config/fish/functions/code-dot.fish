function code-dot
    set -l target $argv[1]
    if test -z "$target"
        set target "."
    end
    env GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME code $target
end

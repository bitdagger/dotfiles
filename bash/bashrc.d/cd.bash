# Make a new directory and cd into it
mkcd() {
    mkdir -p -- "$1" && builtin cd -- "$1"
}
complete -A directory mkcd

# Useful cd replacement
__cd() {
    local arg
    local -a opts
    for arg in "$@" ; do
        case $arg in
            --)
                shift
                break
                ;;
            -*)
                shift
                opts=("${opts[@]}" "$arg")
                ;;
            *)
                break
                ;;
        esac
    done
    if (($# == 2)) ; then
        if [[ "${PWD}" == *"$1"* ]] ; then
            builtin cd "${opts[@]}" -- "${PWD/$1/$2}"
        else
            printf 'bash: cd: could not replace substring\n' >&2
            return 1
        fi
    else
        builtin cd "${opts[@]}" -- "$@"
    fi
}
alias cd="__cd"

# Quick navigation
..() {
    local arg=${1:-1};
    local dir=""
    while [ $arg -gt 0 ]; do
        dir="../$dir"
        arg=$(($arg - 1));
    done
    cd $dir >&/dev/null
}

...() {
    if [ -z "$1" ]; then
        return
    fi
    local maxlvl=16
    local dir=$1
    while [ $maxlvl -gt 0 ]; do
        dir="../$dir"
        maxlvl=$(($maxlvl - 1));
        if [ -d "$dir" ]; then
            cd $dir >&/dev/null
        fi
    done
}

#cd to dir of defined file | Usage: cdf <file>
cdf() { 
  cd "$(dirname "$(locate -i "$*" | head -n 1)")";
}

alias -- -="cd -"

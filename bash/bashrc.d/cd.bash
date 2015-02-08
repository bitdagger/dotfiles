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
alias ..="cd .."
alias -- -="cd -"

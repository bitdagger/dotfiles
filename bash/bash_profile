# Abort if there's no version information (<2.0)
if ! test "$BASH_VERSINFO" ; then
    return
fi

# Source the shell profile if it exists
if [[ -r "${HOME}/.profile" ]]; then
    source "${HOME}/.profile"
fi

# Source the shell config if it exists
if [[ -r "${HOME}/.bashrc" ]]; then
    source "${HOME}/.bashrc"
fi

# Keychain setup
if command -v keychain >/dev/null 2>&1 ; then
    eval "$(TERM=${TERM:-ansi} keychain \
        --eval --ignore-missing --quiet id_dsa id_rsa id_ecsda --agents ssh)"

    # Set and export TTY/GPG_TTY for interactive shells
    if [ -t 0 ] ; then
        GPG_TTY=$(tty)
        export GPG_TTY
    fi
fi

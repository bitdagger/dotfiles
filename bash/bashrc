# Abort if there's no version information (<2.0)
if ! test "$BASH_VERSINFO" ; then
    return
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History control
HISTFILESIZE=0                       # We don't keep anything in the history file anyway
HISTSIZE=$((2 ** 10))                # Keep around 1000 lines of history in memory
HISTCONTROL=ignoreboth               # Ignore duplicate commands and those that start with whitespace
shopt -s histappend                  # In case I ever decide to start keeping history
shopt -s cmdhist                     # Put multiline commands onto one line in the history

# Don't bug me
unset -v MAILCHECK                   # Don't warn me about mail
shopt -u mailwarn                    # Make sure mail warnings are off
setterm -bfreq -blength 2>/dev/null  # Don't beep at me
mesg n                               # Don't let anyone write(1) to me

# Various options
force_color_prompt=yes               # Pretty colors
shopt -s checkhash                   # Update the hash table properly
shopt -s checkwinsize                # Make sure line wrapping on window resize works correctly
shopt -s dotglob                     # Include dotfiles in pattern matching
shopt -s extglob                     # Enable advanced pattern matching
shopt -u hostcomplete                # Don't use Bash's builtin host completion
shopt -s no_empty_cmd_completion     # Ignore empty lines for completion
shopt -s progcomp                    # Use programmable completion, if available
shopt -s shift_verbose               # Warn me if I try to shift when there's nothing there
shopt -u sourcepath                  # Don't use PATH to find files to source

# These options only exist since Bash 4.0-alpha
if ((BASH_VERSINFO[0] >= 4)) ; then
    shopt -s checkjobs               # Warn me about stopped jobs when exiting
    shopt -s globstar                # Enable double-starring paths
fi

# Fix colors in xfce4-terminal
if [ -e /usr/share/terminfo/x/xterm-256color ] && [ "${COLORTERM}" == "xfce4-terminal" ]; then
    export TERM=xterm-256color
fi

# Load any supplementary scripts
if [[ -d "${HOME}/.bashrc.d" ]] ; then
    for config in "${HOME}"/.bashrc.d/*.bash ; do
        source "${config}"
    done
fi
unset -v config

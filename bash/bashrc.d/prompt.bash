# ----------------------------------------------------------------
# Actions to be performed before each prompt is displayed
#
# $1 - boolean - Should the fancy stuff be calculated
# ----------------------------------------------------------------
__pre_prompt() {
    declare -i PROMPT_RETURN=$?
    PROMPT_DATA=()

    local dash=${PROMPT_SYMBOL_DATA[0]}
    local reset=${PROMPT_COLOR_DATA[0]}
    local bold=${PROMPT_COLOR_DATA[1]}
    local white=${PROMPT_COLOR_DATA[2]}
    local pcolor=${PROMPT_PRIMARY_COLOR}

    # Error flag
    PROMPT_DATA[0]=''
    if ((PROMPT_RETURN > 0)) ; then
        PROMPT_DATA[0]="${dash}[${PROMPT_COLOR_DATA[3]}${bold}${PROMPT_SYMBOL_DATA[4]} - ${PROMPT_RETURN}${reset}${pcolor}]"
    fi

    PROMPT_DATA[1]=${PWD/#$HOME/\~} # PWD with home dir abbreviated

    # Git Status
    if [[ -n ${DISABLE_GIT_PROMPT} && "${DISABLE_GIT_PROMPT}" = "1" ]]; then
        # If the prompt has been disabled, bail
        PROMPT_DATA[2]=""
    else
        # Bail if we have no git(1)
        if ! hash git 2>/dev/null ; then
            PROMPT_DATA[2]=""
        else
            # Try to use the gitprompt script
            if [[ $(type -t "__git_ps1") ]]; then
                GIT_PS1_SHOWUPSTREAM="verbose"
                local GitData=$(__git_ps1 | sed -e 's/^ *//' -e 's/ *$//')
                if [[ -z $GitData ]]; then
                    PROMPT_DATA[2]=""
                else
                    local git_status="`git status -unormal 2>&1`"
                    local git_color=$(tput setaf 2)
                    if [[ "${git_status}" =~ can\ be\ fast-forwarded ]]; then
                        git_color=$(tput setaf 6)
                    elif [[ "${git_status}" =~ have\ diverged ]]; then
                        git_color=$(tput setaf 1)
                    elif [[ "${git_status}" =~ nothing\ to\ commit ]]; then
                        git_color=$(tput setaf 2)
                    elif [[ "${git_status}" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
                        git_color=$(tput setaf 4)
                    else
                        git_color=$(tput setaf 3)
                    fi

                    PROMPT_DATA[2]="[${git_color}${GitData}${reset}${pcolor}]${dash}"
                fi

            fi
        fi
    fi

    # Optional components
    if [ $1 == 1 ]; then
        # CPU Usage
        PROMPT_DATA[3]=$(temp=$(cat /proc/loadavg) && echo ${temp%% *})

        # Memory Usage
        local -i memtotal=$(( $(cat /proc/meminfo | head -n 1 | tr -d -c 0-9) / 1024 ))
        local -i memfree=$(( $(cat /proc/meminfo | head -n 2 | tail -n 1 | tr -d -c 0-9) / 1024 ))
        local -i memused=$(( ${memtotal} - ${memfree} ))
        local percentUsed=$(( ${memused} / ${memtotal} ))
        PROMPT_DATA[4]="${memused}/${memtotal} MB"

        # Jobs
        local -i jobc=0
        while read -r _ ; do
            ((jobc++))
        done < <(jobs -p)
        if ((jobc > 0)) ; then
            PROMPT_DATA[5]="${dash}[${white}${bold}${jobc} Jobs${reset}${pcolor}]"
        else
            PROMPT_DATA[5]=""
        fi

        # Battery
            # Bail if we have no upower. We can use /sys/ info, but screw that
            if ! hash upower 2>/dev/null ; then
                PROMPT_DATA[6]=""
            else
                # Bail if we have no battery
                if [[ -z $(upower -e | grep -i battery) ]]; then
                    PROMPT_DATA[6]=""
                else
                    discharging=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -i state | grep discharging)
                    percentage=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -i percent | awk '{print $2}')
                    if [[ -z "${discharging}" ]]; then
                        chargestatus=${PROMPT_SYMBOL_DATA[5]};
                    else
                        chargestatus="";
                    fi

                    PROMPT_DATA[6]="${dash}[${white}${bold}${chargestatus}${percentage}${reset}${pcolor}]"
                fi
            fi
        

        # Wifi
        if [[ -z $(ls /proc/net/wireless) ]]; then
            PROMPT_DATA[7]=""
        else
            local interface=$(cat /proc/net/wireless | tail -n 1 | awk '{print $1}' | rev | cut -c 2- | rev)
            if [[ "${interface}" == "fac" ]]; then
                PROMPT_DATA[7]=""
            else
                local wifistrength=$(awk 'NR==3 {print $3 "00 %"}''' /proc/net/wireless | rev | cut -c 6- | rev)
                local ssid=$(iw dev ${interface} link | grep SSID | awk 'NR==1 {print $2}')

                PROMPT_DATA[7]="${dash}[${white}${bold}${ssid}:${wifistrength}%${reset}${pcolor}]"
            fi
        fi
    fi
}

# ----------------------------------------------------------------
# Select a prompt to use
#
# $1 - string - Prompt to use
# ----------------------------------------------------------------
prompt() {
    if [[ ! $1 ]] ; then
        return
    fi

    # Git prompt function
    case $1 in
        git)
            # If no arguments, output the help
            if [[ ! $2 ]] ; then
                echo "Usage: prompt git <on|off>"
                return
            fi

            case $2 in
                on)
                    DISABLE_GIT_PROMPT=0
                    ;;
                off)
                    DISABLE_GIT_PROMPT=1
                    ;;
                *)
                    printf '%s: Unknown command %s\n' "${FUNCNAME}" "$2" >&2
                    return 1
            esac

            return
            ;;
    esac

    # Get number of colors supported by the terminal
    local -i icolors=$( {
        tput Co || tput colors
    } 2>/dev/null )

    # Define some colors
    local color_data=()
    color_data[0]=$( { # Reset
        tput me || tput sgr0
    } 2>/dev/null )
    color_data[1]=$( { # Bold
        tput md || tput bold
    } 2>/dev/null )
    color_data[2]=$( { # White
        tput AF 7 || tput setaf 7
    } 2>/dev/null )
    color_data[3]=$( { # Red
        tput AF 1 || tput setaf 1
    } 2>/dev/null )

    # Set blue and green based on the number of colors supported
    color_data[4]=$( { # Blue
            tput AF 7 || tput setaf 7
        } 2>/dev/null )
    color_data[5]=$( { # Green
            tput AF 7 || tput setaf 7
        } 2>/dev/null )
    if ((icolors == 256)) ; then
        color_data[4]=$( {
            tput AF 27 || tput setaf 27 || tput AF 27 0 0 || tput setaf 27 0 0
        } 2>/dev/null )
        color_data[5]=$( {
            tput AF 82 || tput setaf 82 || tput AF 82 0 0 || tput setaf 82 0 0
        } 2>/dev/null )
    elif ((icolors == 8)) ; then
        color_data[4]=$( {
            tput AF 4 || tput setaf 4
        } 2>/dev/null )
        color_data[5]=$( {
            tput AF 2 || tput setaf 2
        } 2>/dev/null )
    fi

    # Determine the symbols used in the prompt
    local symbol_data=("-" "-" "-" "-", "X", "+")
    if [ $(locale charmap) = "UTF-8" ]; then
        symbol_data[0]="─"
        symbol_data[1]="┌"
        symbol_data[2]="├"
        symbol_data[3]="└"
        symbol_data[4]="✗"
        symbol_data[5]="⚡"
    fi

    # Check to see if we're an SSH session
    local SESSION_TYPE="local"
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
      SESSION_TYPE="ssh"
    else
      case $(ps -o comm= -p ${PPID}) in
        sshd|*/sshd) SESSION_TYPE="ssh";;
      esac
    fi

    # Set the prompt color based on the current user and SSH status
    local primary_color=${color_data[4]}    # Blue
    if [[ ${EUID} == 0 ]] ; then
        primary_color=${color_data[3]}      # Red
    elif [ ${SESSION_TYPE} == "ssh" ]; then
        primary_color=${color_data[5]}      # Green
    fi

    # Set titlebar info if xterm/rxvt
    case $TERM in
        xterm*|rxvt*)
            local TITLEBAR='\[\033]0;\u@\h:\l (\w) [${COLUMNS}x${LINES}]\007\]';;
        *)
            local TITLEBAR="";;
    esac

    # Actual prompt selection
    case $1 in
        # Full featured prompt
        on)
            PROMPT_COLOR_DATA=("${color_data[@]}")
            PROMPT_SYMBOL_DATA=("${symbol_data[@]}")
            PROMPT_PRIMARY_COLOR=${primary_color}
            PROMPT_COMMAND="__pre_prompt 1"

            local pc=${primary_color}
            local r=${color_data[0]}
            local b=${color_data[1]}
            local pfc=${color_data[2]}
            local d=${symbol_data[0]}
            local c1=${symbol_data[1]}
            local c2=${symbol_data[3]}
            local pipe=${symbol_data[2]}
            local hc=${pfc}
            if [ ${SESSION_TYPE} == "ssh" ]; then
                hc=${color_data[3]}
            fi

            local Line1="${TITLEBAR}\[${pc}\]${c1}${d}"                         # Graphics
            Line1="${Line1}[\[${pfc}${b}\]\t\[${r}${pc}\]]${d}"                 # Current time
            Line1="${Line1}[\[${hc}${b}\]\u@\H:\l\[${r}${pc}\]]"                   # Hostname
            Line1="${Line1}${d}[\[${pfc}${b}\]\${PROMPT_DATA[3]}\[${r}${pc}\]]" # CPU Usage
            Line1="${Line1}${d}[\[${pfc}${b}\]\${PROMPT_DATA[4]}\[${r}${pc}\]]" # Memory Usage
            Line1="${Line1}\${PROMPT_DATA[5]}"                                  # Jobs
            Line1="${Line1}\${PROMPT_DATA[6]}"                                  # Battery
            Line1="${Line1}\${PROMPT_DATA[7]}"                                  # Wifi

            local Line2="\[${pc}\]${pipe}${d}\${PROMPT_DATA[2]}"                # Git Prompt
            Line2="${Line2}[\[${pfc}${b}\]\${PROMPT_DATA[1]}\[${r}${pc}\]]"     # PWD
            Line2="${Line2}\${PROMPT_DATA[0]}"                                  # Error

            local Line3="\[${pc}\]${c2}${d}\$ "

            PS1="\[${r}\]\n${Line1}\n${Line2}\n${Line3}\[${r}\]"
            PS2="\[${r}\]\[${pc}\]${c2}${d}> \[${r}\]"
            PS3='? '
            PS4='+ '
            ;;

        # Simpler, but still pretty prompt
        simple)
            PROMPT_COLOR_DATA=("${color_data[@]}")
            PROMPT_SYMBOL_DATA=("${symbol_data[@]}")
            PROMPT_PRIMARY_COLOR=${primary_color}
            PROMPT_COMMAND="__pre_prompt 0"

            local pc=${primary_color}
            local r=${color_data[0]}
            local b=${color_data[1]}
            local pfc=${color_data[2]}
            local d=${symbol_data[0]}
            local c1=${symbol_data[1]}
            local c2=${symbol_data[3]}
            local pipe=${symbol_data[2]}
            local hc=${pfc}
            if [ ${SESSION_TYPE} == "ssh" ]; then
                hc=${color_data[3]}
            fi

            local Line1="${TITLEBAR}\[${pc}\]${c1}${d}"                         # Graphics
            Line1="${Line1}[\[${pfc}${b}\]\t\[${r}${pc}\]]${d}"                 # Current time
            Line1="${Line1}[\[${hc}${b}\]\u@\H\[${r}${pc}\]]"                   # Hostname

            local Line2="\[${pc}\]${pipe}${d}\${PROMPT_DATA[2]}"                # Git Prompt
            Line2="${Line2}\[${pfc}${b}\]\${PROMPT_DATA[1]}\[${r}${pc}\]]"      # PWD
            Line2="${Line2}\${PROMPT_DATA[0]}"                                  # Error

            local Line3="\[${pc}\]${c2}${d}\$ "

            PS1="\[${r}\]\n${Line1}\n${Line2}\n${Line3}\[${r}\]"
            PS2="\[${r}\]\[${pc}\]${c2}${d}> \[${r}\]"
            PS3="${color_data[0]}? "
            PS4="${color_data[0]}+ "
            ;;

        # Revert to simple inexpensive prompt
        off)
            unset -v PROMPT_COMMAND PROMPT_DIRTRIM PROMPT_RETURN 
            unset -v PROMPT_COLOR_DATA PROMPT_SYMBOL_DATA PROMPT_PRIMARY_COLOR
            PS1="${color_data[0]}\n\$ "
            PS2="${color_data[0]}> "
            PS3="${color_data[0]}? "
            PS4="${color_data[0]}+ "
            ;;

        # Print error
        *)
            printf '%s: Unknown prompt %s\n' "${FUNCNAME}" "$1" >&2
            return 1
    esac
}

# Default to a fully featured prompt
prompt on

prompt() {

	# If no arguments, do nothing
    if [[ ! $1 ]] ; then
        return
    fi

	# Get color info and set the reset variable
	local -i colors=$( {
        tput Co || tput colors
    } 2>/dev/null )
	local reset=$( {
        tput me || tput sgr0
    } 2>/dev/null )

	# Declare Unicode
    local dash="\342\224\200"
    local corner1="\342\224\214"
    local midpipe="\342\224\234"
    local corner2="\342\224\224"

	# Set the colors
	local white=$( {
            tput AF 7 || tput setaf 7
        } 2>/dev/null )
	local red=$( {
            tput AF 1 || tput setaf 1
        } 2>/dev/null )
	local bold=$( {
            tput md || tput bold
        } 2>/dev/null )

	# Set the blue and green colors based on the number of colors the terminal supports
	local blue
    local green
    if ((colors == 256)) ; then
        blue=$( {
            tput AF 27 || tput setaf 27 || tput AF 27 0 0 || tput setaf 27 0 0
        } 2>/dev/null )
        green=$( {
            tput AF 82 || tput setaf 82 || tput AF 82 0 0 || tput setaf 82 0 0
        } 2>/dev/null )
    elif ((colors == 8)) ; then
        blue=$( {
            tput AF 4 || tput setaf 4
        } 2>/dev/null )
        green=$( {
            tput AF 2 || tput setaf 2
        } 2>/dev/null )
    else
        blue=$( {
            tput AF 7 || tput setaf 7
        } 2>/dev/null )
        green=$( {
            tput AF 7 || tput setaf 7
        } 2>/dev/null )
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
    local pcolor=${blue}
    if [[ ${EUID} == 0 ]] ; then
        pcolor=${red}   # Root gets red
    elif [ $SESSION_TYPE == "ssh" ]; then
        pcolor=${green} # SSH gets green
    fi

    case $1 in
    	# Full featured prompt
        on)
			PROMPT_COMMAND='declare -i PROMPT_RETURN=$?'
            PROMPT_COLOR='35;1m'

			# If Bash 4.0 is available, trim very long paths in prompt
            if ((BASH_VERSINFO[0] >= 4)) ; then
                PROMPT_DIRTRIM=4
            fi

		    # Set the hostname color to red if we're ssh'd, white otherwise
		    local hostname
            if [ $SESSION_TYPE == "ssh" ]; then
		        hostname="[\[${red}${bold}\]\u@\H\[${reset}${pcolor}\]]"
		    else
		        hostname="[\[${white}${bold}\]\u@\H\[${reset}${pcolor}\]]"
		    fi

		    local Line1="\[${pcolor}\]${corner1}${dash}[\[$white$bold\]\t\[$reset$pcolor\]]${dash}${hostname}${dash}\$(prompt cpu)${dash}\$(prompt memory)\$(prompt jobs)"
		    local Line2="\[${pcolor}\]${midpipe}${dash}\$(prompt git)[\[${white}${bold}\]\${PWD}\[${reset}${pcolor}\]]\$(prompt error)"
		    local CVSLine=""
		    local Line3="\[${pcolor}\]${corner2}${dash}\$ "

		    PS1="\n${Line1}\n${Line2}\n${CVSLine}${Line3}\[${reset}\]"
            PS2='> '
            PS3='? '
            PS4='+ '
			;;

    	# Revert to simple inexpensive prompts
        off)
            unset -v PROMPT_COMMAND PROMPT_DIRTRIM PROMPT_RETURN
            PROMPT_COLOR='35;1m'
            PS1="\n\$ "
            PS2="> "
            PS3="? "
            PS4="+ "
            ;;

        # CPU block
        cpu)
			local cpu=$(temp=$(cat /proc/loadavg) && echo ${temp%% *})
			echo "[${white}${bold}${cpu}${reset}${pcolor}]"
            ;;

        # Memory block
        memory)
			local -i memtotal=$(( $(cat /proc/meminfo | head -n 1 | tr -d -c 0-9) / 1024 ))
			local -i memfree=$(( $(cat /proc/meminfo | head -n 2 | tail -n 1 | tr -d -c 0-9) / 1024 ))
			local -i memused=$(( ${memtotal} - ${memfree} ))
			local percentUsed=$(( ${memused} / ${memtotal} ))
			echo "[${white}${bold}${memused}/${memtotal} MB${reset}${pcolor}]"
			;;

        # Jobs block
        jobs)
			local -i jobc=0
            while read -r _ ; do
                ((jobc++))
            done < <(jobs -p)
            if ((jobc > 0)) ; then
            	echo -ne "\xE2\x94\x80"
            	echo "[${white}${bold}${jobc} Jobs${reset}${pcolor}]"
            fi
            ;;

        # Error block
        error)
			if ((PROMPT_RETURN > 0)) ; then
				echo -e "\xE2\x94\x80[${red}${bold}\xE2\x9c\x97${reset}${pcolor}]"
            fi
            ;;

        # Git prompt function
        git)
            # If no arguments, output the prompt
            if [[ ! $2 ]] ; then

                # If the prompt has been disabled, bail
                if [[ -n ${DISABLE_GIT_PROMPT} && "${DISABLE_GIT_PROMPT}" = "1" ]]; then
                    return 0
                fi

                # Bail if we have no git(1)
                if ! hash git 2>/dev/null ; then
                    return 1
                fi

                # Try to use the gitprompt script
                if [[ $(type -t "__git_ps1") ]]; then
                    GIT_PS1_SHOWUPSTREAM="verbose"
                	GitData=$(__git_ps1 | sed -e 's/^ *//' -e 's/ *$//')
                	if [[ -z $GitData ]]; then
                		return 1;
            		fi
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

                	echo -e "[${git_color}${GitData}${reset}${pcolor}]\xE2\x94\x80"

                	return 0
                fi

                return 0
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
            ;;

    	# Print error
        *)
            printf '%s: Unknown command %s\n' "${FUNCNAME}" "$1" >&2
            return 1
    esac
}

# Default to a full featured prompt
prompt on

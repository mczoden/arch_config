#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

bashrc_alias()
{
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -A'

    alias mv='mv -iv'
    alias rm='rm -iv'
    alias cp='cp -iv'

    alias grep='grep --color=auto'

    alias pwd='pwd -P'

    if [ $UID -ne 0 ]; then
        alias poweroff='sudo systemctl poweroff'
        alias reboot='sudo systemctl reboot'
    fi
}

bashrc_export_environment_variable()
{
    export BROWSER="chromium"
    export HISTCONTROL=ignoreboth
    export EDITOR="vim"
    export GREP_COLOR=36
}

bashrc_PS1()
{
    local NONE="\[\033[0m\]"    # unsets color to term's fg color

    # regular colors
    local K="\[\033[0;30m\]"    # black
    local R="\[\033[0;31m\]"    # red
    local G="\[\033[0;32m\]"    # green
    local Y="\[\033[0;33m\]"    # yellow
    local B="\[\033[0;34m\]"    # blue
    local M="\[\033[0;35m\]"    # magenta
    local C="\[\033[0;36m\]"    # cyan
    local W="\[\033[0;37m\]"    # white

    # emphasized (bolded) colors
    local EMK="\[\033[1;30m\]"
    local EMR="\[\033[1;31m\]"
    local EMG="\[\033[1;32m\]"
    local EMY="\[\033[1;33m\]"
    local EMB="\[\033[1;34m\]"
    local EMM="\[\033[1;35m\]"
    local EMC="\[\033[1;36m\]"
    local EMW="\[\033[1;37m\]"

    # background colors
    local BGK="\[\033[40m\]"
    local BGR="\[\033[41m\]"
    local BGG="\[\033[42m\]"
    local BGY="\[\033[43m\]"
    local BGB="\[\033[44m\]"
    local BGM="\[\033[45m\]"
    local BGC="\[\033[46m\]"
    local BGW="\[\033[47m\]"

    if [[ $UID == 0 ]]; then
        PS1="${W}┌─[${EMR}\u@\h${W}][${EMB}\w${W}]\n└─╼${NONE} "
    else
        PS1="${W}┌─[${G}\u@\h${W}][${EMB}\w${W}]\n└─╼${NONE} "
        # PS1="${K}┌─[${EMG}\u@\h${K}][${EMB}\w${K}]\n└─╼${NONE} "
    fi
}

bashrc_dircolors()
{
    eval `dircolors`
}

syns()
{
    synergys --config /etc/synergy.conf
}

pmount()
{
    if mount | grep -q $1; then
        echo "Device has been mounted"
        return
    fi

    local dev_name=`basename $1`

    if [ -e /tmp/$dev_name ]; then
        if [ ! -d /tmp/$dev_name ]; then
            echo "/tmp/$dev_name is existed but not a directory"
            return
        fi
    else
        mkdir /tmp/$dev_name
    fi

    sudo mount --option utf8,uid=$UID $1 /tmp/$dev_name
}

pumount()
{
    if ! mount | grep -q $1; then
        echo "Device hasn't been mounted"
        return
    fi

    sudo umount $1
}

pytags()
{
    ctags --python-kinds=-i $@
}

upgrade()
{
    case `uname -a` in
        *ARCH*)
            sudo pacman -Syu
            ;;
        *Darwin*)
            brew upgrade
            ;;
        *)
            echo No upgrade method.
            ;;
    esac
}

bashrc_alias
bashrc_export_environment_variable
bashrc_PS1
# bashrc_dircolors

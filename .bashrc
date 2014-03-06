#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
#PS1='[\u@\h \W]\$ '

alias ls='ls -G'
alias ll='ls -ahlF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep -n --color'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

alias pwd='pwd -P'
alias wlftp='lftp -u ftpuser,scFt1pp'
alias tlftp='lftp -u ftpuser,kxcnd0l8f9cfqit3'
alias smb_send="smbclient -U 'sdc/10555%Echeveria.1310' \
    //ftmoutside.sdc.sercomm.com/Send \
    -D 10555"
alias smb_recv="smbclient -U 'sdc/10555%Echeveria.1310' \
    //ftmoutside.sdc.sercomm.com/Receive \
    -D inside_s_sdc_sercomm_com/10555"
alias rd="rdesktop -K -f -u 10555 sercomm-280ebf4.SDC.SERCOMM.COM"
alias vi="vim"

alias ssh='TERM=screen ssh'
alias pyhttp="python2.7 -m SimpleHTTPServer"

#alias reboot="sudo umount /mnt/smb_recv/; reboot"
#alias poweroff="sudo umount /mnt/smb_recv/; poweroff"

export LS_COLORS="*.tar=01;31:*.tgz=01;31:*.gz=01;31:*.bz2=01;31:*.rar=01;31:*.zip=01;31:*.xz=01;31"
export BROWSER="chromium"
export HISTCONTROL=ignoreboth
export EDITOR="vim"
export GREP_COLOR=36
#[[ -n "$TMUX" ]] && [[ -e /usr/share/terminfo/s/screen-256color ]] && export TERM="screen-256color"
#[[ -n $DISPLAY ]] && export TERM="rxvt-unicode-256color"

less_termcap()
{
    export LESS_TERMCAP_mb=$'\E[01;31m'
    export LESS_TERMCAP_md=$'\E[01;31m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;44;33m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[01;32m'
}

bash_prompt() {
    #    case $TERM in
    #     xterm*|rxvt*)
    #         local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
    #          ;;
#     *)
    #         local TITLEBAR=""
    #          ;;
    #    esac
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

    #    local UC=$W                 # user's color
    #    [ $UID -eq "0" ] && UC=$R   # root's color

    #    PS1="$TITLEBAR ${EMK}[${UC}\u${EMK}@${UC}\h ${EMB}\${NEW_PWD}${EMK}]${UC}\\$ ${NONE}"
    # without colors: PS1="[\u@\h \${NEW_PWD}]\\$ "
    # extra backslash in front of \$ to make bash colorize the prompt

    if [[ $UID == 0 ]]; then
        PS1="${W}┌─[${EMR}\u@\h${W}][${EMB}\w${W}]\n└─╼${NONE} "
    else
        # PS1="${W}┌─[${G}\u@\h${W}][${EMB}\w${W}]\n└─╼${NONE} "
        PS1="${K}┌─[${EMG}\u@\h${K}][${EMB}\w${K}]\n└─╼${NONE} "
    fi
    #┌
    #└────■
    #╼
}

bash_prompt
#less_termcap
#PS1="[\u@\h][\w]\n$ "

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

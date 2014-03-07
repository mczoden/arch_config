#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice

# Simple X enviroment selector with .xinitrc.
# ERROR: But not useful.
#
# Author: McZoden
# Version: 0.0.2.2
# Date: 2014/02/26

# Step of adding a new X environment:
#
# 1 Insert the X environment into xinitrc_xenv_name_tbl.
# 2 Create the execution handler with name xinitrc_${xenv_name}_exec_hdl.
#                                                  ^
#                                      the name you added in step 1.
# 3 Optional step: modify the xinitrc_dfl_xenv_name with the new one.

# X environment name table and the default one.
# Only latin letters a-z or A-Z are allowed.
xinitrc_xenv_name_tbl=( \
    'dwm' \
    'openbox' \
    )
xinitrc_dfl_xenv_name='dwm'

[ ${#xinitrc_xenv_name_tbl[@]} -eq 0 ] || [ ${#xinitrc_dfl_xenv_name} -eq 0 ] && exit

# Error code definition
#
# DO NOT edit this variable.
ERROR_CODE=255

# Basic X environment setting function
xinitrc_xsetroot()
{
    while true; do
        xsetroot -name "`date '+%a %d %b %T'`"
        sleep 1
    done &
}

xinitrc_xset()
{
    # Font path could be set in xorg.conf.
    xset +fp /usr/share/fonts/wenquanyi/wqy-microhei
    xset +fp /usr/share/fonts/local
    xset fp rehash
}

xinitrc_xresources()
{
    [ -f ~/.Xresources ] && xrdb ~/.Xresources
}

xinitrc_ibus()
{
    export GTK_IM_MODULE=ibus
    export XMODIFIERS=@im=ibus
    export QT_IM_MODULE=ibus
    ibus-daemon -rxd
}

# X environment execution handler
#
# Name of haldler MUST follow format:
# xinitrc_${xenv_name}_exec_hdl
#         ^
# one of elements in array xinitrc_xenv_name_tbl
xinitrc_dwm_exec_hdl()
{
    xinitrc_xsetroot
    xinitrc_xresources
    xinitrc_ibus
    exec dwm
}

xinitrc_openbox_exec_hdl()
{
    # NOTE:
    #
    # Use ~/.config/openbox/environment to export environment variable.
    # Use ~/.config/openbox/autostart to launch program.
    # Do NOTHING here if possible.

    exec openbox-session
}

xinitrc_get_xenv_idx_by_name()
{
    local xenv_name='' idx=0

    for xenv_name in ${xinitrc_xenv_name_tbl[@]}; do
        if [ $1 == $xenv_name ]; then
            return $idx
        fi
        ((idx++))
    done

    return $ERROR_CODE
}

xinitrc_check_xenv_exec_hdl()
{
    local xinitrc_defined_xenv_exec_hdl_tbl=( $(declare -F | grep xinitrc_[[:alpha:]]*_exec_hdl$ | awk '{print $3}') )
    local xenv_name='' xenv_exec_hdl='' idx=0 defined_hdl_num=0 c='' ret=''

    for xenv_name in ${xinitrc_xenv_name_tbl[@]}; do
        idx=0
        defined_hdl_num=${#xinitrc_defined_xenv_exec_hdl_tbl[@]}
        for xenv_exec_hdl in ${xinitrc_defined_xenv_exec_hdl_tbl[@]}; do
            if [ $xenv_exec_hdl == "xinitrc_${xenv_name}_exec_hdl" ]; then
                unset xinitrc_defined_xenv_exec_hdl_tbl[$idx]
                break
            fi
            ((idx++))
        done

        if [ $idx -eq $defined_hdl_num ]; then
            echo "X environment \"$xenv_name\" has no execution handler."
            while true; do
                # read -p "Stop and add \"xinitrc_${xenv_name}_exec_hdl\"? [Y/n] " c
                c='y'
                case $c in
                    'y' | 'Y')
                        return $ERROR_CODE
                        break
                        ;;
                    'n' | 'N')
                        xinitrc_get_xenv_idx_by_name $xenv_name
                        idx=$?
                        unset xinitrc_xenv_name_tbl[$idx]
                        break
                        ;;
                    *)
                        continue
                        ;;
                esac
            done
        fi
    done

    return 0
}

xinitrc_print_xenv_name_tbl()
{
    local xenv_name='' idx=0

    for xenv_name in ${xinitrc_xenv_name_tbl[@]}; do
        echo -n $((idx++)): $xenv_name
        if [ $xenv_name == $xinitrc_dfl_xenv_name ]; then
            echo " (default)"
        else
            echo
        fi
    done
}

xinitrc_get_dfl_xenv_idx()
{
    local idx=0

    xinitrc_get_xenv_idx_by_name $xinitrc_dfl_xenv_name
    idx=$?
    if [ $idx -eq $ERROR_CODE ]; then
        echo "No xenv named \"${xinitrc_dfl_xenv_name}\" found!"
        idx=0
        echo "Use ${xinitrc_xenv_name_tbl[0]} as the default X environment!"
    fi

    return $idx
}

xinitrc_gen_xenv_exec_hdl_tbl()
{
    local xenv_name='' idx=0

    for xenv_name in ${xinitrc_xenv_name_tbl[@]}; do
        xinitrc_xenv_exec_hdl_tbl[$((idx++))]="xinitrc_${xenv_name}_exec_hdl"
    done
}

xinitrc_isdigit()
{
    [ $# -eq 1 ] || return $ERROR_CODE

    case $1 in
        *[!0-9]*|"")
            return $ERROR_CODE
            ;;
        *)
            return 0
            ;;
    esac
}

xinitrc_select_and_exec_xenv()
{
    local idx=0

    while true; do
        xinitrc_print_xenv_name_tbl
        read -p "Please select: " idx
        if xinitrc_isdigit $idx; then
            break
        fi
    done

    ${xinitrc_xenv_exec_hdl_tbl[$idx]}
}

xinitrc_get_xenv_idx_by_name $xinitrc_dfl_xenv_name
xinitrc_dfl_xenv_idx=$?
if [ $xinitrc_dfl_xenv_idx -eq $ERROR_CODE ]; then
    echo "Default X environment \"$xinitrc_dfl_xenv_name\" isn't in array xinitrc_xenv_name_tbl"
    exit 1
fi

xinitrc_check_xenv_exec_hdl
[ $? -eq $ERROR_CODE ] && exit 1
declare -a xinitrc_xenv_exec_hdl_tbl
xinitrc_gen_xenv_exec_hdl_tbl
${xinitrc_xenv_exec_hdl_tbl[$xinitrc_dfl_xenv_idx]}
# xinitrc_select_and_exec_xenv

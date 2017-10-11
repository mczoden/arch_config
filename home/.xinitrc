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

# Basic X environment setting function
xinitrc_driver()
{
    # VDPAU
    # AMD
    # xf86-video-ati and mesa-vdpau installed.
    #
    # https://wiki.archlinux.org/index.php/VDPAU
    export VDPAU_DRIVER=r600

    # VA-API
    # AMD
    # libva-vdpau-driver and mesa-dri
	#
	# https://wiki.archlinux.org/index.php/VA-API
    export LIBVA_DRIVER_NAME=vdpau
}

xinitrc_xsetroot()
{
    while true; do
        xsetroot -name "`date '+%a %d %b %H:%M'`"
        sleep 1m
    done &
}

xinitrc_xset()
{
    # Font path could be set in xorg.conf.
    xset +fp /usr/share/fonts/wenquanyi/wqy-microhei
    xset +fp /usr/share/fonts/wenquanyi
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

xinitrc_volumeicon()
{
    volumeicon &
}

xinitrc_wallpaper()
{
    local wallpaper=''
    local wallpaper_list=( \
        '' \
        'wallpaper-552587_yui.png' \
        'wallpaper-553897_mio.png' \
        'wallpaper-552586_ritsu.png' \
        'wallpaper-540131_mugi.png' \
        'wallpaper-545909_azusa.png' \
        'wallpaper-564738_ui.png' \
        'wallpaper-702897_nodoka.png' \
        )

    # feh --bg-fill "$HOME/pic/kon/${wallpaper_list[`date +%u`]}" &
	# feh --bg-fill "$HOME/pic/wallhaven/wallhaven-4145.png"
	feh --bg-fill "$HOME/pic/wallhaven/wallhaven-8893.jpg"
}

xinitrc_xcompmgr()
{
    xcompmgr -c -n &
}

xinitrc_locale()
{
    export LANG=zh_CN.UTF-8
    export LANGUAGE=zh_CN:en_US
    export LC_CTYPE=en_US.UTF-8
}

xinitrc_mpd()
{
    [[ -f ~/./mpd/pid ]] || mpd
}

xinitrc_dwm_exec_hdl()
{
    xinitrc_driver
    xinitrc_xset
    xinitrc_xsetroot
    xinitrc_xresources
    xinitrc_wallpaper
    xinitrc_xcompmgr
    xinitrc_locale
    xinitrc_ibus

    exec dwm > ~/.dwm.log 2>&1
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

xinitrc_awesome_exec_hdl()
{
    xinitrc_driver
    xinitrc_xset
    xinitrc_xresources
    xinitrc_xcompmgr
    # xinitrc_wallpaper
    xinitrc_locale
    # xinitrc_volumeicon
    xinitrc_ibus
    # nm-applet &

    exec awesome > ~/.awesome.log 2>&1
}

session=${1:-awesome}

case $session in
    awesome)
        xinitrc_awesome_exec_hdl
        ;;
    dwm)
        xinitrc_dwm_exec_hdl
        ;;
    *)
        exec $1
        ;;
esac

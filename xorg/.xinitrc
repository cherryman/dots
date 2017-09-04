#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?* ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xrdb -merge $HOME/.Xresources
xmodmap $HOME/.Xmodmap

# Disable mouse accel
xset m 1 0

# Default wm is i3wm
wm="${2-i3}"

# Start programs
case "$wm" in

    "i3" | "bspwm")
        sxhkd &
        compton &
        dunst &
        feh --bg-scale $wallp
        ;;
    *)
        ;;
esac

redshift -t6500:3400 -b1.0:0.9 &

# Start wm
exec $wm

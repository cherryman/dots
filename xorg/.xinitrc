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
redshift -t6500:3200 -b1.0:0.8 &

case "$wm" in

    "i3" | "bspwm")
        sxhkd &
        compton &
        dunst &
        ;;
    *)
        ;;
esac

# Start wm
exec $wm

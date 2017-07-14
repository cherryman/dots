#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?* ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xrdb -merge $HOME/.Xresources
xmodmap $HOME/.Xmodmap

xset m 1 0

sxhkd &
compton &
dunst &
redshift -t6500:3200 -b1.0:0.8 &


# i3 if first argument isn't given to startx
exec ${2-i3}

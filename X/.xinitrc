#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?* ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xrdb -merge $HOME/.Xresources
xmodmap $HOME/.Xmodmap

PATH="$HOME/.config/sxhkd:$PATH" sxhkd &
compton &
dunst &
redshift -t6500:3200 -b1.0:0.8 &

exec i3

#!/bin/sh

pr="%{R}%{R}"
pl="%{F#f4aa00}%{B#dddddd}%{R}"

bg="%{B#141021}"

reset="%{-o}$bg%{F#dddddd}"
sel="%{+o}%{B#222222}%{F#dddddd}%{u#aa33aa}"
urg="%{+o}%{B#222222}%{F#dddddd}%{u#f40000}"
sep="        "

alias p='echo -n'

{

p "$reset"

### Left
p "%{l}"

#p "<<"
#p "i3ws -S -B "
#p "-f '$reset  ' '  ' "
#p "-F '$sel  ' '  ' "
#p "-u '$urg  ' '  '"
#p ">>"

p "<<"
p "bspwmws -B "
p " -n '$reset  ' -N '  '"
p " -f '$sel  '   -F '  '"
p ">>"

p "$reset"

### Center
p "%{c}"

#p "$sel"
#p "<<i3window>>"
#p "$reset"

### Right
p "%{r}"

p "$sel"
p " <<clock '+%a, %d %b %H:%M'>> "
p "$reset"
p "$sep"

p "%{A4:volume up:}%{A5:volume down:}"
p "$sel"
p "   <<vol>> "
p "$reset"
p "%{A}%{A}"

# Requires a patched lemonbar for xft support
} | genbar -b'<<' -e'>>' \
  | lemonade -b \
        -u 2 -g "1920x27+0+0" \
        -f "Noto Sans 12" \
        -f "Hack 12" \
        -f "FontAwesome 12" \
  |sh #&> /dev/null

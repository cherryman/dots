#!/bin/sh

reset="%{-o}%{B#141021}%{F#dddddd}"
sel="%{+o}%{B#222222}%{F#dddddd}%{U#aa33aa}"
urg="%{+o}%{B#222222}%{F#dddddd}%{U#f40000}"
sep="        "

{

echo -n "$reset"

### Left
echo -n "%{l}"

echo -n "<<"
echo -n "i3ws -S -B "
echo -n "-f '$reset  ' '  $reset' "
echo -n "-F '$sel  ' '  $reset' "
echo -n "-u '$urg  ' '  $reset'"
echo -n ">>"


### Center
echo -n "%{c}"

echo -n "$sel"
echo -n "<<i3window>>"
echo -n "$reset"

### Right
echo -n "%{r}"

echo -n "$sel"
echo -n " <<clock '+%a, %d %b %H:%M'>> "
echo -n "$reset"
echo -n "$sep"

echo -n "%{A4:volume up:}%{A5:volume down:}"
echo -n "$sel"
echo -n "   <<vol>> "
echo -n "$reset"
echo -n "%{A}%{A}"

# Requires a patched lemonbar for xft support
} | genbar -db '<<' -de '>>' | lemonbar -u 2 -a 20 -b -o '1' -f "Noto Sans" -o '-1' -f "FontAwesome"| sh &> /dev/null

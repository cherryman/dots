#!/bin/sh

echo $DOTDIR
cd "$DOTDIR/_bar"
PATH="$DOTDIR/_bar:$DOTDIR/_bar/block:$PATH"

reset="%{B#000000}%{F#DDDDDD}"
sel="%{B#222222}%{F#FFFFFF}"
sep="        "

{

echo -n "$reset"
echo -n "%{U#aa33aa}"

### Left
echo -n "%{l}"

echo -n "<<"
echo -n "i3ws -S -B "
echo -n "-f '$reset  ' '  $reset' "
echo -n "-F '%{+o}$sel  ' '  $reset%{-o}' "
echo -n "-u '%{B#DD7744}%{F#DDDDDD}  ' '  $reset'"
echo -n ">>"


### Center
echo -n "%{c}"

echo -n "%{+o}"
echo -n "$sel"
echo -n "<<i3window>>"
echo -n "$reset"
echo -n "%{-o}"

### Right
echo -n "%{r}"

echo -n "%{+o}"
echo -n "$sel"
echo -n "<<clock '+%a, %d %b %H:%M'>>"
echo -n "$reset"
echo -n "%{-o}"
echo -n "$sep"

echo -n "%{+o}"
echo -n "%{A4:volume up:}%{A5:volume down:}"
echo -n "$sel"
echo -n "  <<vol>> "
echo -n "$reset"
echo -n "%{A}%{A}"
echo -n "%{-o}"

# Requires a patched lemonbar for xft support
} | genbar -db '<<' -de '>>' | lemonbar -u 2 -a 20 -b -o '1' -f "Noto Sans" -o '-1' -f "FontAwesome"| sh &> /dev/null

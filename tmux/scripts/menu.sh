#!/bin/sh

item() {
    cmd="$1"
    echo "new -s'$cmd' '$cmd && tmux switch -t\"$sess\"'"
}

sess="$(tmux display-message -p "#S")"
tmux display-menu -x R -y P \
    "Spotify" s "$(item spt)" \
    "Mail"    m "$(item aerc)" \
    "Monitor" p "$(item htop)" \
    "Files"   f "$(item ranger)" \
    "" \
    "Close"   q ""

#!/bin/sh

sess=$(tmux display-message -p "#S")
pwd=$(tmux display-message -p "#{pane_current_path}")

cmd() {
    # Setup
    printf %s 'tmux set status off;'

    # Command
    # Execution stops here until command ends.
    printf '%s ' "$@"; printf ';'

    # Restore
    printf %s "tmux switch -t\"$sess\";"

    # Newline
    echo
}

item() {
    echo "new -s'$1' '$(cmd "$@")'"
}

tmux display-menu -x R -y P \
    "Spotify" s "$(item spt)" \
    "Mail"    m "$(item aerc)" \
    "Monitor" p "$(item btop)" \
    "Files"   f "$(item ranger "$pwd")" \
    "" \
    "Close"   q ""

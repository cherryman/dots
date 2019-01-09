{ { have fzf && FZF_BIN=fzf; } ||
{ have fzy && FZF_BIN=fzy; } } &&

menu() {
    progs="vim mail files mon"
    if [ -z "$TMUX" ]; then
        progs="${progs} tmux"
    fi

    case "$FZF_BIN" in
        fzf)
            len="$(echo "$progs" | wc -w)"
            len="$((len + 2))" # +2 to account for fzf prompt
            FZF_BIN="$FZF_BIN --height '$len'"
            ;;
        fzy)
            ;;
    esac

    result="$(
        echo "$progs"       |
        tr '[:space:]' '\n' |
        eval "$FZF_BIN"
    )"

    case "$result" in
        mail)  mutt ;;
        files) ranger ;;
        mon)   htop ;;
        tmux)  tmux attach ;;
        *) eval "$result" ;;
    esac
}

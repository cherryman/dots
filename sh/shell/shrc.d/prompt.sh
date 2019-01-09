min_path() {
    dir="$1"

    case "$dir" in
        "$HOME")
            echo '~'
            return ;;
        "$HOME"*)
            dir="${dir#$HOME}"
            minpath='~' ;;
    esac

    dir="${dir#/}"
    while [ "$dir" != "${dir##*/}" ]; do
        d="${dir%%/*}"
        minpath="$minpath/${d%${d#?}}"
        dir="${dir#*/}"
    done

    echo "$minpath/$dir"
    unset minpath dir d
}

ESC="" # escape character
CLR_BLUE="${ESC}[34m"
CLR_RST="${ESC}[00m"
PS1='[$(min_path $PWD)] ' # colors added in shell's rc

if   [ "$BASH" ];     then PS1="\[$CLR_BLUE\]$PS1\[$CLR_RST\]"
elif [ "$ZSH_NAME" ]; then PS1="%{$CLR_BLUE%}$PS1%{$CLR_RST%}"
else PS1="$CLR_BLUE$PS1$CLR_RST"
fi

unset ESC CLR_BLUE CLR_RST

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

esc_print() {
    if   [ "$BASH" ];     then echo "\[$*\]"
    elif [ "$ZSH_NAME" ]; then echo "%{$*%}"
    else echo "$*"
    fi
}

esc="" # escape character
clr_blue="${esc}[34m"
clr_rst="${esc}[00m"
PS1='[$(min_path "$PWD")] ' # colors added in shell's rc
PS1="$(esc_print "$clr_blue")$PS1$(esc_print "$clr_rst")"

unset esc clr_blue clr_rst

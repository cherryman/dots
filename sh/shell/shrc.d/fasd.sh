if have fasd; then

    arg=
    if   [ "$BASH" ];     then arg='bash-hook'
    elif [ "$ZSH_NAME" ]; then arg='zsh-hook'
    else                  arg='posix-hook'
    fi

    eval "$(fasd --init $arg)"
    unset arg

    z()  { cd "$(fasd -d "$@")"; }
    zz() { cd "$(fasd -d -i "$@")"; }
fi

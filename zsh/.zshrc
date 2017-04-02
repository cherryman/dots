source ~/.zplug/init.zsh

# Packages


# Theme
zplug themes/agnoster, from:oh-my-zsh


autoload -Uz compinit
compinit -D

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+r:|[._-]=** r:|=**'
zstyle ':completion:*' menu select

unsetopt beep
bindkey -v


# Install packages not installed
if ! zplug check --verbose; then
    printf "Install? [Y/n]: "
    if read -q; then
        echo
    else
        echo; zplug install
    fi
fi

zplug load

### ENV
BASE16_SHELL="$HOME/.config/base16-shell"
DOTDIR="$HOME/dotfiles"
GOPATH="$HOME/.local"
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
ZPLUG_HOME="$HOME/.config/zplug"


### Source
source "$ZPLUG_HOME/init.zsh"
[ -n "$PS1" ] \
    && [ -s $BASE16_SHELL/profile_helper.sh ] \
    && eval "$($BASE16_SHELL/profile_helper.sh)"


### Plug
zplug 'modules/prompt', from:prezto
zplug 'plugins/git', from:oh-my-zsh


### ZSH Settings
zstyle ':prezto:module:prompt' theme 'agnoster'

autoload -Uz compinit
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
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

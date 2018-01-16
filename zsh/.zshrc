### ENV
export BASE16_SHELL="$HOME/.config/base16-shell"
export ZPLUG_HOME="$HOME/.config/zplug"
export PYENV_ROOT="$HOME/.config/pyenv"

export FZF_DEFAULT_COMMAND="rg --files --hidden --color never --ignore-file .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"

export EDITOR=vim
export PAGER=less
export LESS="-R"
export GOPATH="$HOME/.local/go"
export PATH="$HOME/bin:$HOME/.local/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PATH"

export TENDERBLOCKS="$ZPLUG_HOME/repos/Snowlabs/bartender/block"

export TERMINAL=alacritty
export WALLPAPER="$HOME/Pictures/wallpaper"
export DOTDIR="$HOME/dotfiles"


### Source
source "$ZPLUG_HOME/init.zsh"
[ -n "$PS1" ] \
    && [ -s $BASE16_SHELL/profile_helper.sh ] \
    && eval "$($BASE16_SHELL/profile_helper.sh)"


### Alias
alias has='command -v &> /dev/null'

has exa && alias tree='exa -T'
has exa && alias ls='exa'
alias l='ls -l'

alias v='f -f -e vim'
alias m='f -f -e mplayer'
alias o='a -e xdg-open'

has nvim && alias vim='nvim'

has thefuck && eval $(thefuck --alias)
has pyenv && eval "$(pyenv init - )"
eval "$(fasd --init posix-alias zsh-hook)"


### Plug
zplug 'modules/helper', from:prezto
zplug 'modules/editor', from:prezto
zplug 'modules/git', from:prezto

zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions'
zplug 'modules/prompt', from:prezto
zplug 'zsh-users/zsh-syntax-highlighting'

zplug 'clvv/fasd', use:fasd, as:command
zplug 'pepa65/tldr-bash-client', use:'tldr', as:command, rename-to:tldr
zplug 'junegunn/fzf', use:'shell/*.zsh', if:"(( $+commands[fzf] ))", defer:1

zplug 'ogham/exa', from:gh-r, as:command, rename-to:exa
zplug 'BurntSushi/ripgrep', from:gh-r, as:command, rename-to:rg
zplug 'junegunn/fzf-bin', from:gh-r, as:command, rename-to:fzf

zplug 'Snowlabs/bartender', use:genbar, as:command


### ZSH Settings
zstyle ':prezto:module:prompt' theme 'sorin'

autoload -Uz compinit
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' menu select

setopt hist_ignore_space hist_reduce_blanks extended_history
setopt inc_append_history_time hist_find_no_dups

unsetopt beep

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

# Widgets
less-widget() {
    BUFFER+=" | ${PAGER:-more}"
    zle accept-line
}

session-selector-widget() {
    local sess
    sess="$(abduco | tail -n +2 | fzf | cut -f 3)"
    if [[ -n "$sess" ]]; then
        BUFFER="abduco -a '$sess'"
        zle accept-line
    fi
}

zle -N less-widget
zle -N session-selector-widget

# Keybinds
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget
bindkey '\eo' less-widget
bindkey '\es' session-selector-widget

### ENV
export BASE16_SHELL="$HOME/.config/base16-shell"
export ZPLUG_HOME="$HOME/.config/zplug"
export PYENV_ROOT="$HOME/.config/pyenv"

export EDITOR=vim
export DOTDIR="$HOME/dotfiles"
export GOPATH="$HOME/.local/go"
export PATH="$HOME/bin:$HOME/.local/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PATH"


### Source
source "$ZPLUG_HOME/init.zsh"
[ -n "$PS1" ] \
    && [ -s $BASE16_SHELL/profile_helper.sh ] \
    && eval "$($BASE16_SHELL/profile_helper.sh)"


### Alias
alias ls='ls --color=always'
alias l='ls -l'
eval $(thefuck --alias)

hash pyenv 2> /dev/null && eval "$(pyenv init - )"


### Plug
zplug 'modules/helper', from:prezto
zplug 'modules/editor', from:prezto
zplug 'modules/git', from:prezto

zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions'
zplug 'modules/prompt', from:prezto
zplug 'zsh-users/zsh-syntax-highlighting'

zplug 'rupa/z', use:z.sh
zplug 'ogham/exa', from:gh-r, as:command, rename-to:exa
zplug 'junegunn/fzf-bin', from:gh-r, as:command, rename-to:fzf
zplug 'BurntSushi/ripgrep', from:gh-r, as:command, rename-to:rg

### ZSH Settings
zstyle ':prezto:module:prompt' theme 'sorin'

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

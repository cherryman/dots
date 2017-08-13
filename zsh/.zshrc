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

# Custom
export term=alacritty
export wallp="$HOME/Pictures/wallpaper"
export dotdir="$HOME/dotfiles"


### Source
source "$ZPLUG_HOME/init.zsh"
[ -n "$PS1" ] \
    && [ -s $BASE16_SHELL/profile_helper.sh ] \
    && eval "$($BASE16_SHELL/profile_helper.sh)"


### Alias

function exists() {
    command -v $1 &> /dev/null
    return $?
}

exists exa && alias ls='exa'
alias l='ls -l'

exists thefuck && eval $(thefuck --alias)
exists pyenv && eval "$(pyenv init - )"


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
zplug 'BurntSushi/ripgrep', from:gh-r, as:command, rename-to:rg

zplug 'junegunn/fzf-bin', from:gh-r, as:command, rename-to:fzf
zplug 'junegunn/fzf', use:'shell/*.zsh', defer:1

### ZSH Settings
zstyle ':prezto:module:prompt' theme 'sorin'

autoload -Uz compinit
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' menu select

unsetopt beep

# Keybinds
bindkey -v
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget
bindkey '^R' fzf-history-widget


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


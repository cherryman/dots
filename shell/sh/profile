have() {
    command -v "$1" > /dev/null
}


# Environment variables
export XDG_CONFIG_COME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export WALLPAPER="$HOME/media/pic/wallp"
export DOTDIR="$HOME/dotfiles"

export LESS="-RSi"
export CARGO_HOME="$HOME/$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$HOME/$XDG_DATA_HOME/rustup"
export GOPATH="$HOME/$XDG_DATA_HOME/go"

have vim   && export EDITOR=vim && export VISUAL=vim
have less  && export PAGER=less
have dmenu && export LAUNCHER=dmenu_run
have cargo && export PATH="$CARGO_HOME/bin:$PATH"
have go    && export PATH="$GOPATH/bin:$PATH"

for t in alacritty xterm; do
    have "$t" && export TERMINAL="$t" && break
done; t=

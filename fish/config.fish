set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

set -gx BASE16_SHELL "$HOME/.config/base16-shell"
set -gx LESS "-RSi"
set -gx MOSH_ESCAPE_KEY '' # <C-\>
set -gx export GOPROXY "direct"
set -gx NIXPKGS_ALLOW_UNFREE 1

set -gx SCREENSHOT_DIR "$HOME/media/pic/sshot"

set -gx LESSHISTFILE "$XDG_STATE_HOME/lesshst"
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -gx GOPATH "$XDG_DATA_HOME/go"
set -gx PYTHONSTARTUP "$XDG_CONFIG_HOME/pythonrc.py"
set -gx TEXMFHOME "$XDG_DATA_HOME/texmf"
set -gx TEXMFCONFIG "$XDG_CONFIG_HOME/texmf"
set -gx TEXMFVAR "$XDG_CACHE_HOME/texmf"
set -gx CABAL_CONFIG "$XDG_CONFIG_HOME/cabal/config"
set -gx CABAL_DIR "$XDG_CACHE_HOME/cabal"
set -gx GRADLE_USER_HOME "$XDG_DATA_HOME/gradle"
set -gx STACK_ROOT "$XDG_DATA_HOME/stack"
set -gx OCTAVE_HISTFILE "$XDG_STATE_HOME/octave_hist"
set -gx PSQL_HISTORY "$XDG_CACHE_HOME/psql_history"
set -gx DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
set -gx NODE_REPL_HISTORY "$XDG_STATE_HOME/node_repl_history"
set -gx CUDA_CACHE_PATH "$XDG_CACHE_HOME/nv"
set -gx QMK_HOME "$XDG_DATA_HOME/qmk_firmware"
set -gx ELAN_HOME "$XDG_DATA_HOME/elan"

set -gx GTK_IM_MODULE wayland
set -gx QT_IM_MODULE fcitx
set -gx XMODIFIERS @im fcitx

if type -q eza
    alias ls 'eza'
    alias tree 'eza -T'
end

alias e nvim
alias l 'ls -l'
alias tm tmux
alias tf terraform
alias g git
alias c cargo
alias n nix
alias nb numbat
alias py python
alias ipy ipython
alias x xonsh
alias j just

if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
end

if type -q less
    set -gx PAGER less
end

fish_add_path "$XDG_CONFIG_HOME/emacs/bin"
fish_add_path "$GOPATH/bin"
fish_add_path "$CARGO_HOME/bin"
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"

if type -q /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

begin
    set -l nix_profile "$XDG_STATE_HOME/nix/profiles/profile"
    set -l hmvars "$nix_profile/etc/profile.d/hm-session-vars.sh"

    if test -f "$nix_profile/etc/profile.d/nix.fish"
        source "$nix_profile/etc/profile.d/nix.fish"
    else if test -f /usr/etc/profile.d/nix.fish
        source /usr/etc/profile.d/nix.fish
    else if test -f /etc/profile.d/nix.fish
        source /etc/profile.d/nix.fish
    end

    if type -q babelfish && test -f $hmvars
        babelfish < $hmvars > /dev/null
     end

    # nix being weird as usual.
    # https://nixos.wiki/wiki/Locales
    if test -z $LOCAL_ARCHIVE && test -f "/usr/lib/locale/locale-archive"
        set -gx LOCAL_ARCHIVE "/usr/lib/locale/locale-archive"
    end
end

if status is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"

    type -q fzf; and fzf --fish | source
    type -q zoxide; and zoxide init fish | source
    type -q direnv; and direnv hook fish | source

    function execute_to_pager
        commandline -a " &| $PAGER"
        commandline -f execute
    end

    bind \eo execute_to_pager
end

function prompt_hostname --description 'short hostname for the prompt'
    string replace -r -- "\..*" "" $hostname
end

function prompt_login --description 'display user name for the prompt'
    if not set -q __fish_machine
        set -g __fish_machine
        set -l debian_chroot $debian_chroot

        if test -r /etc/debian_chroot
            set debian_chroot (cat /etc/debian_chroot)
        end

        if set -q debian_chroot[1]
            and test -n "$debian_chroot"
            set -g __fish_machine "(chroot:$debian_chroot)"
        end
    end

    # Prepend the chroot environment if present
    if set -q __fish_machine[1]
        echo -n -s (set_color yellow) "$__fish_machine" (set_color normal) ' '
    end

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY; and set -q fish_color_host_remote
        set color_host $fish_color_host_remote
    end

    if set -q SSH_TTY; or not string match -qr 'cherry*|macbook*|MacBook*' (hostname)
            set -f host "@$(set_color $color_host)$(prompt_hostname)$(set_color normal)"
    end

    if test "$USER" != "sheheryar"
        set -f user "$(set_color $fish_color_user)$USER$(set_color normal)"
    end

    echo -n -s $user $host
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    set suffix "$(set_color brblack)$suffix$(set_color normal)"

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) (set_color brblack) (fish_vcs_prompt) $normal " "$prompt_status " " $suffix " "
end

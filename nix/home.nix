{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  py-solders = (pkgs.callPackage ./pkgs/py-solders.nix { });
  py-solana = (pkgs.callPackage ./pkgs/py-solana.nix { solders = py-solders; });
in
{
  home.enableNixpkgsReleaseCheck = false;

  # `home-manager switch` failing breaks `home-manager`, so not enabling.
  programs.home-manager.enable = false;

  # source one of
  #
  # ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  # ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  # /etc/profiles/per-user/sheheryar/etc/profile.d/hm-session-vars.sh
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # read release notes before updating.
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # unfortunately difficult to run anything with hardware accel.
    # https://github.com/nix-community/nixGL/issues/114

    babelfish
    basedpyright
    biber
    biff
    bitwarden-cli
    bun
    cachix
    carapace
    cargo-bloat
    cargo-deny
    cargo-expand
    cargo-show-asm
    cargo-udeps
    cargo-watch
    cargo-zigbuild
    comma
    curl
    dig
    direnv
    elan
    entr
    eza
    fd
    ffmpeg
    fzf
    gh
    git
    git-absorb
    git-lfs
    git-subrepo
    gradle
    graphite-cli
    grpcurl
    hexyl
    hyperfine
    imagemagick
    img2pdf
    irssi
    inshellisense
    jq
    just
    kotlin-language-server
    ktfmt
    lldb
    lsof
    ncdu
    pkgs-unstable.neovim-unwrapped # 0.12.5
    nix-index-unwrapped
    nixfmt-rfc-style
    nixos-generators
    nixpkgs-review
    nodejs
    numbat
    openfortivpn
    openvpn
    ouch
    p7zip
    pandoc
    poetry
    prettier
    pscale
    qmk
    qrencode
    restic
    ripgrep
    ripgrep-all
    rsync
    ruff
    rustup
    sentry-cli
    shellcheck
    socat
    syncthing
    terraform
    texlab
    tinymist
    tmux
    tokei
    tokio-console
    tree-sitter
    typescript-language-server
    typst
    typstyle
    util-linux
    uv
    wabt
    websocat
    wget
    xh
    yarn
    yazi
    yt-dlp
    zbar
    zig
    zls
    zoxide

    # ctf / pentest
    aircrack-ng
    apktool
    binutils
    binwalk
    boundary
    cyberchef
    dex2jar
    exiftool
    foremost
    frida-tools
    ghidra
    john
    mitmproxy
    mtr
    netcat-gnu
    nmap
    radare2
    volatility3
    wireshark

    # ai stuff
    # amp-cli
    # claude-code
    codex
    gemini-cli
    opencode

    (pkgs.wordlists.override {
      lists = with pkgs; [
        nmap
        rockyou
        seclists
        wfuzz
      ];
    })

    (pkgs.callPackage ./pkgs/ipsw.nix { })
    (pkgs.callPackage ./pkgs/amp-cli.nix { })

    (python313.withPackages (p: [
      p.base58
      p.cryptography
      p.editorconfig # doom emacs optimization
      p.frida-python
      p.ipython
      p.jupyter-core
      p.numpy
      p.pandas
      p.pillow
      p.pwntools
      p.pymupdf
      p.pypdf
      p.requests
      p.spotipy
      p.sympy
      p.torch
      p.xonsh
      (p.callPackage ./pkgs/pyrekordbox.nix { })
    ]))

    (pass.withExtensions (ext: [
      ext.pass-otp
    ]))

    (pkgs.lib.setPrio (-1) moreutils) # override `errno` from `pwntools`
    (pkgs.lib.setPrio (-2) parallel) # override `parallel` from `moreutils`

    # install `codelldb` for use with debug adapter protocol
    # https://github.com/vadimcn/codelldb/issues/310#issuecomment-786082362
    (writeShellScriptBin "codelldb" ''
      exec ${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
    '')

    # fonts
    source-sans
    source-serif
    source-code-pro
    source-han-sans
    source-han-serif
    source-han-mono
    noto-fonts-color-emoji
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
  };

  services = {
    syncthing.enable = true;
  };

  home.file.".codex/AGENTS.md".source = # .
    ../AGENTS.md;

  home.file.".claude/CLAUDE.md".source = # .
    ../AGENTS.md;

  xdg.configFile."mpv/scripts".source =
    let
      drv = pkgs.symlinkJoin {
        name = "mpv-scripts";
        paths = with pkgs.mpvScripts; [
          autoload
          # compilation broken due to some binary signing
          autosubsync-mpv
          # https://github.com/mrxdst/webtorrent-mpv-hook/commit/d3381c92d08b2506700e33aae7ce02f18e15431f
          webtorrent-mpv-hook
        ];
      };
    in
    "${drv}/share/mpv/scripts";

  xdg.configFile."mpv/shaders".source = # .
    "${pkgs.callPackage ./pkgs/mpv-shaders.nix { }}";

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      update_ms = 1000;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      # https://rgoswami.me/posts/poetry-direnv/
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          log_error 'No pyproject.toml found.  Use `poetry new` or `poetry init` to create one first.'
          exit 2
        fi

        local VENV=$(dirname $(poetry run which python))
        export VIRTUAL_ENV=$(echo "$VENV" | rev | cut -d'/' -f2- | rev)
        export POETRY_ACTIVE=1
        PATH_add "$VENV"
      }

      # https://github.com/direnv/direnv/wiki#uv
      layout_uv() {
          if [[ -d ".venv" ]]; then
              VIRTUAL_ENV="$(pwd)/.venv"
          fi

          if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
              log_status "No virtual environment exists. Executing \`uv venv\` to create one."
              uv venv
              VIRTUAL_ENV="$(pwd)/.venv"
          fi

          PATH_add "$VIRTUAL_ENV/bin"
          export UV_ACTIVE=1  # or VENV_ACTIVE=1
          export VIRTUAL_ENV
      }
    '';
  };
}

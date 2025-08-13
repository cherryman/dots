{ config, pkgs, ... }:
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
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # unfortunately difficult to run anything with hardware accel.
    # https://github.com/nix-community/nixGL/issues/114

    babelfish
    basedpyright
    biber
    biff
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
    neovim
    nix-index-unwrapped
    nixfmt-rfc-style
    nixos-generators
    nixpkgs-review
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs
    numbat
    openfortivpn
    openvpn
    p7zip
    pandoc
    poetry
    qmk
    qrencode
    restic
    ripgrep
    ripgrep-all
    rsync
    ruff
    rustup
    shellcheck
    socat
    syncthing
    terraform
    texlab
    tinymist
    tmux
    tokei
    tokio-console
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
    netcat-gnu
    nmap
    radare2
    volatility3
    wireshark

    (pkgs.wordlists.override {
      lists = with pkgs; [
        nmap
        rockyou
        seclists
        wfuzz
      ];
    })

    # custom
    (pkgs.callPackage ./pkgs/rebiber.nix { })
    (pkgs.callPackage ./pkgs/cfddns.nix { })
    (pkgs.callPackage ./pkgs/sif.nix { })
    (pkgs.callPackage ./pkgs/zotra.nix { })
    (pkgs.callPackage ./pkgs/ipsw.nix { })

    (python312.withPackages (p: [
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
      p.sympy
      p.torch
      p.xonsh
      py-solders
      py-solana
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
    frequency = "weekly";
    persistent = true;
  };

  services = {
    syncthing.enable = true;
  };

  # should port this to darwin with launchd. see examples:
  # https://github.com/nix-community/home-manager/tree/master/modules/launchd
  # https://github.com/nix-community/home-manager/blob/e1aec543f5caf643ca0d94b6a633101942fd065f/modules/services/syncthing.nix#L100
  systemd.user.services.zotra =
    let
      zotra = pkgs.callPackage ./pkgs/zotra.nix { };
    in
    {
      Unit.Description = "zotra server";
      Unit.After = [ "network.target" ];
      Install.WantedBy = [ "default.target" ];
      Service.ExecStart = "${zotra}/bin/zotra server";
    };

  xdg.configFile."mpv/scripts".source =
    let
      drv = pkgs.symlinkJoin {
        name = "mpv-scripts";
        paths = with pkgs.mpvScripts; [
          autoload
          autosubsync-mpv
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

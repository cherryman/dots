{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.username = "sheheryar";

  home.homeDirectory =
    if pkgs.stdenv.isLinux then
      "/home/sheheryar"
    else if pkgs.stdenv.isDarwin then
      "/Users/sheheryar"
    else
      throw "unsupported platform";

  # read release notes before updating.
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # unfortunately difficult to run anything with hardware accel.
    # https://github.com/nix-community/nixGL/issues/114

    biber
    btop
    bun
    cachix
    cargo-bloat
    cargo-deny
    cargo-expand
    cargo-llvm-cov
    cargo-show-asm
    cargo-udeps
    cargo-vet
    cargo-watch
    cargo-zigbuild
    curl
    dig
    direnv
    elan
    entr
    eza
    fd
    fzf
    gh
    git-absorb
    git-subrepo
    grpcurl
    hexyl
    hyperfine
    jq
    jupyter
    just
    kotlin-language-server
    lsof
    ncdu
    neovim
    nix-direnv
    nixfmt-rfc-style
    nixos-generators
    nodePackages.prettier
    numbat
    p7zip
    pandoc
    poetry
    pyright
    qmk
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
    tmux
    tokei
    tokio-console
    typescript-language-server
    typst
    typst-lsp
    wabt
    xh
    yazi
    zig
    zls
    zoxide

    # analysis
    frida-tools
    ghidra
    mitmproxy
    nmap
    radare2
    wireshark

    # custom
    (pkgs.callPackage ../pkgs/rebiber.nix { })
    (pkgs.callPackage ../pkgs/cfddns.nix { })
    (pkgs.callPackage ../pkgs/sif.nix { })

    # not installing `parallel` in favor of `moreutils`, see:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=597050#75
    moreutils

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

    # doom emacs needs this for performance
    python312Packages.editorconfig
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
      zotra = pkgs.callPackage ../pkgs/zotra.nix { };
    in
    {
      Unit.Description = "zotra server";
      Unit.After = [ "network.target" ];
      Install.WantedBy = [ "default.target" ];
      Service.ExecStart = "${zotra}/bin/zotra server";
    };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sheheryar/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # `home-manager switch` failing breaks `home-manager`, so not enabling.
  programs.home-manager.enable = false;
}

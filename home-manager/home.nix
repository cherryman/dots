{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sheheryar";
  home.homeDirectory = "/home/sheheryar";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # unfortunately difficult to run anything with hardware accel.
    # https://github.com/nix-community/nixGL/issues/114

    black
    brightnessctl
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
    curl
    dig
    direnv
    elan
    eww
    fd
    fzf
    gh
    git-subrepo
    grpcurl
    hexyl
    hyperfine
    jq
    jupyter
    just
    kotlin-language-server
    ktfmt
    ncdu
    ngrok
    nixfmt-rfc-style
    nmap
    nodePackages.prettier
    p7zip
    pandoc
    poetry
    pyright
    qmk
    restic
    ripgrep
    rsync
    ruff
    rustup
    shellcheck
    socat
    swww
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

    # not installing `parallel` in favor of `moreutils`, see:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=597050#75
    moreutils

    # fonts
    source-code-pro
    source-sans-pro
    source-serif-pro
    source-han-sans
    source-han-serif
    noto-fonts-color-emoji

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    persistent = true;
  };

  services = {
    ssh-agent.enable = true;
    syncthing.enable = true;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
}

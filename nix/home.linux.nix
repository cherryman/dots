{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
    cargo-llvm-cov # broken on darwin
    cargo-vet # broken on darwin
    eww
    grim
    playerctl
    slurp
    swww
    wl-clipboard
    wlsunset
  ];

  gtk = {
    enable = true;
    theme.package = pkgs.matcha-gtk-theme;
    theme.name = "Matcha-dark-pueril";
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  services = {
    ssh-agent.enable = true;
  };
}

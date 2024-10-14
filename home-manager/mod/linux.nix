{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
    eww
    grim
    ktfmt
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

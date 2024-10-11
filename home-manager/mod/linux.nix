{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    ktfmt
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
}

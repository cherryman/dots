{
  config,
  pkgs,
  lib,
  ...
}:
{
  # nixGL not needed and no wayland/x11 issues, so including gui apps.
  #
  # spotlight ignores symlinked .app files, to fix:
  # https://github.com/hraban/mac-app-util
  home.packages = with pkgs; [
    alacritty
    deluge
    emacs
    mpv
  ];
}

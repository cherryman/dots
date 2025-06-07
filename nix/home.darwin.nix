{
  config,
  pkgs,
  lib,
  ...
}:
{
  # nixGL not needed and no wayland/x11 issues, so including gui apps.
  # omitting discord due to the stupid update check.
  home.packages = with pkgs; [
    aerospace
    alt-tab-macos
    anki-bin
    audacity
    emacs
    imhex
    maccy
    mpv-unwrapped
    raycast
    slack
    spotify
    utm
    zathura
  ];

  # https://github.com/nix-community/home-manager/blob/master/modules/targets/darwin/keybindings.nix
  targets.darwin.keybindings = {
    "^u" = "deleteToBeginningOfLine:";
    "^w" = "deleteWordBackward:";
    "~f" = "moveWordForward:";
    "~b" = "moveWordBackward:";
    "~d" = "deleteWordForward:";
  };
}

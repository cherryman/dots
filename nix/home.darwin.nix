{
  config,
  pkgs,
  lib,
  ...
}:
let
  scrotDir = "${config.home.homeDirectory}/Pictures/screenshots";
in
{
  # nixGL not needed and no wayland/x11 issues, so including gui apps.
  home.packages = with pkgs; [
    aerospace
    alt-tab-macos
    anki-bin
    audacity
    deluge
    discord
    emacs
    imhex
    maccy
    mpv-unwrapped
    raycast
    slack
    thunderbird-latest-unwrapped
    utm
    zathura
    zotero

    (pkgs.callPackage ./pkgs/rapidraw.nix { })
  ];

  home.activation.fuck-you-discord =
    let
      jq = "${pkgs.jq}/bin/jq";
      sponge = "${pkgs.moreutils}/bin/sponge";
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settings="$HOME/Library/Application Support/discord/settings.json"

      if [[ -f "$settings" ]]; then
        ${jq} '.SKIP_HOST_UPDATE = true' "$settings" | ${sponge} "$settings"
      else
        mkdir -p "$(dirname "$settings")"
        echo '{ "SKIP_HOST_UPDATE": true }' > "$settings"
      fi
    '';

  # https://github.com/nix-community/home-manager/blob/master/modules/targets/darwin/keybindings.nix
  targets.darwin.keybindings = {
    "^u" = "deleteToBeginningOfLine:";
    "^w" = "deleteWordBackward:";
    "~f" = "moveWordForward:";
    "~b" = "moveWordBackward:";
    "~d" = "deleteWordForward:";
  };

  targets.darwin.defaults = {
    "com.apple.screencapture" = {
      location = scrotDir;
    };
  };

  # ensure that "com.apple.screencapture".location exists. defaults to ~/Desktop otherwise.
  home.activation.ensure-screencapture-location = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${scrotDir}"
  '';
}

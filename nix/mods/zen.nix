{
  config,
  lib,
  pkgs,
  ...
}:
let
  zenConfigDir = if pkgs.stdenv.isDarwin then "Library/Application Support/zen" else ".zen";
  zenRoot = "${config.home.homeDirectory}/${zenConfigDir}";
in
{
  # Seed the profile list once; Zen manages its install-specific entries afterward.
  home.activation.zenProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${zenRoot}/Profiles/default" "${zenRoot}/Profiles/re"
    if [ ! -e "${zenRoot}/profiles.ini" ]; then
      install -m 600 ${./zen-profiles.ini} "${zenRoot}/profiles.ini"
    fi
  '';

  home.file."${zenConfigDir}/Profiles/re/user.js" = {
    force = true;
    source = ./zen-re-user.js;
  };

  home.file."bin/zen-re" = {
    force = true;
    source = ./zen-re.sh;
  };
}

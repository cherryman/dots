{ pkgs, ... }:
let
  zotra = pkgs.callPackage ../pkgs/zotra.nix { };
in
{
  home.packages = [
    zotra
  ];
  systemd.user.services.zotra = {
    Unit.Description = "zotra server";
    Unit.After = [ "network.target" ];
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = "${zotra}/bin/zotra server";
  };
}

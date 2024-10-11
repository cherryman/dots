{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          packages = {
            zotra = pkgs.callPackage ./pkgs/zotra.nix { };
            rebiber = pkgs.callPackage ./pkgs/rebiber.nix { };
            cfddns = pkgs.callPackage ./pkgs/cfddns.nix { };
          };
        };
      flake = {
        homeConfigurations =
          let
            linux-modules = [
              ./mod/base.nix
              ./mod/linux.nix
              ./mod/zotra.nix
            ];
          in
          {
            "sheheryar@cherrylt" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.aarch64-linux;
              modules = linux-modules;
            };
            "sheheryar@cherrypc" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              modules = linux-modules;
            };
          };
      };
    };
}

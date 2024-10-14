{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pinned to audited commit.
    mac-app-util = {
      url = "github:hraban/mac-app-util/9c6bbe2a6a7ec647d03f64f0fadb874284f59eac";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      mac-app-util,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
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
        };
      flake = {
        homeConfigurations = {
          "sheheryar@cherrylt" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-linux;
            modules = [
              ./mod/base.nix
              ./mod/linux.nix
              ./mod/zotra.nix
            ];
          };
          "sheheryar@cherrypc" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./mod/base.nix
              ./mod/linux.nix
              ./mod/zotra.nix
            ];
          };
          "sheheryar@macbook" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            modules = [
              mac-app-util.homeManagerModules.default
              ./mod/base.nix
              ./mod/darwin.nix
            ];
          };
        };
      };
    };
}

{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        homeConfigurations =
          let
            linux-modules = [
              ./home.nix
              ./home.linux.nix
            ];
            darwin-modules = [
              ./home.nix
              ./home.darwin.nix
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
            "sheheryar@macbook" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.aarch64-darwin;
              modules = darwin-modules;
            };
          };
      };
    };
}

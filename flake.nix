{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      pkgs-unstable-module =
        { pkgs, ... }:
        {
          _module.args.pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = pkgs.stdenv.hostPlatform.system;
          };
        };
    in
    {
      darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            system.primaryUser = "sheheryar";
            users.users.sheheryar.name = "sheheryar";
            users.users.sheheryar.home = "/Users/sheheryar";
            home-manager.users."sheheryar" = {
              imports = [
                (_: {
                  home.username = "sheheryar";
                  home.homeDirectory = "/Users/sheheryar";
                })
                pkgs-unstable-module
                ./nix/home.nix
                ./nix/home.darwin.nix
              ];
            };
          }
          ./nix/darwin.nix
        ];
      };
      homeConfigurations =
        let
          linux-modules = [
            (_: {
              nixpkgs.config.allowUnfree = true;
              home.username = "sheheryar";
              home.homeDirectory = "/home/sheheryar";
            })
            pkgs-unstable-module
            ./nix/home.nix
            ./nix/home.linux.nix
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
}

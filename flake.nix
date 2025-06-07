{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/adaa24fbf46737f3f1b5497bf64bae750f82942e";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    {
      darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          ./nix/nix-darwin.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."sheheryar" = {
              imports = [
                ./nix/home.nix
                ./nix/home.darwin.nix
              ];
            };
          }
        ];
      };
      homeConfigurations =
        let
          linux-modules = [
            (_: { nixpkgs.config.allowUnfree = true; })
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

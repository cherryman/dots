{
  description = "Home Manager configuration of sheheryar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zotra.url = "./flakes/zotra";
    rebiber.url = "./flakes/rebiber";
  };

  outputs =
    inputs@{
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
        { };
      flake = {
        homeConfigurations =
          let
            allowUnfreeModule = ({ nixpkgs.config.allowUnfree = true; });

            extraPackages = system: ({
              home.packages = map (name: inputs.${name}.packages.${system}.default) [
                "zotra"
                "rebiber"
              ];
            });

            # https://haseebmajid.dev/posts/2023-10-08-how-to-create-systemd-services-in-nix-home-manager/
            zotraService = system: ({
              systemd.user.services.zotra = {
                Unit.Description = "zotra server";
                Unit.After = [ "network.target" ];
                Install.WantedBy = [ "default.target" ];
                Service.ExecStart = "${inputs.zotra.packages.${system}.default}/bin/zotra server";
              };
            });
          in
          {
            "sheheryar@cherrylt" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.aarch64-linux;

              modules = [
                allowUnfreeModule
                (extraPackages "aarch64-linux")
                (zotraService "aarch64-linux")
                ./home.nix
              ];
            };
          };
      };
    };
}

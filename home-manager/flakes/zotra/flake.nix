{
  description = "flake for zotra server";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
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
        let
          src = pkgs.fetchFromGitHub {
            owner = "mpedramfar";
            repo = "zotra-server";
            fetchSubmodules = true;
            rev = "06164a3c169a8ca4f20cec7d0be41d255be8d701";
            sha256 = "sha256-sHyTNuuKZ2TqpdfqJiMLJ3E+ROfR4oTa8nZU5PIFcUg=";
          };
          packageJson = builtins.fromJSON (builtins.readFile "${src}/package.json");
        in
        rec {
          apps.default = {
            type = "app";
            program = "${packages.default}/bin/zotra";
          };

          packages.default = pkgs.buildNpmPackage {
            inherit src;

            pname = packageJson.name;
            version = packageJson.version;
            npmDepsHash = "sha256-b6blHwzNP0vOfqGDMBYmRiD6k9k+YcjVcg0QEKOjgL0";
            makeCacheWritable = true;
            dontNpmBuild = true;

            meta = with pkgs.lib; {
              description = packageJson.description;
              license = licenses.mit;
            };

            installPhase = ''
              mkdir -p $out/lib/node_modules/zotra
              cp -r . $out/lib/node_modules/zotra
              mkdir -p $out/bin
              ln -s $out/lib/node_modules/zotra/bin/index.js $out/bin/zotra
            '';
          };
        };
    };
}

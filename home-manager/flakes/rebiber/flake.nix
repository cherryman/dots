{
  description = "flake for rebiber";

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
          version = "1.1.3";
          src = pkgs.fetchFromGitHub {
            owner = "yuchenlin";
            repo = "rebiber";
            fetchSubmodules = true;
            rev = "v${version}";
            sha256 = "sha256-htf2qy/jIJQKkaPZB/9Yc9OZ1AZrRhpcxzf/G+UWAMY=";
          };
          reqsTxt = pkgs.lib.readFile "${src}/requirements.txt";
          reqs = pkgs.lib.splitString "\n" (builtins.replaceStrings [ "==" ] [ "" ] reqsTxt);
          pythonEnv = pkgs.python3.withPackages (
            pypkgs: map (req: builtins.getAttr (pkgs.lib.toLower req) pypkgs) reqs
          );
        in
        rec {
          apps.default = {
            type = "app";
            program = "${packages.default}/bin/rebiber";
          };
          packages.default = pkgs.python3.pkgs.buildPythonPackage {
            inherit src version;
            pname = "rebiber";
            format = "setuptools";
            doCheck = false;
            propagatedBuildInputs = [ pythonEnv ];
          };
        };
    };
}

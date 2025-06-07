# used `orjson` as a reference for building with `maturin`.
# https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/development/python-modules/orjson/default.nix
{
  lib,
  stdenv,
  python3Packages,
  fetchPypi,
  maturin,
  rustPlatform,
  pkg-config,
  libiconv,
  perl,
}:
let
  pname = "solders";
  version = "0.26.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BXUziS1vpDLBzh4vXjQogClkZmwQtX09G8qrhilfBGw=";
  };
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-mAUb6hXE9yvQGKMnvLkPrmKK8Tep1ZPY0+/KRVUtBvg=";
  };

  # inlining this because it's literally a one-line package ???
  jsonalias =
    let
      pname = "jsonalias";
      version = "0.1.1";
    in
    python3Packages.buildPythonPackage {
      inherit pname version;
      pyproject = true;
      nativeBuildInputs = [ python3Packages.poetry-core ];
      src = fetchPypi {
        inherit pname version;
        hash = "sha256-ZPBNk1OX1Xn8lFCeH8tiEvLQgSNdnWOVvRC67fdgp2k=";
      };
    };
in
python3Packages.buildPythonPackage {
  inherit
    pname
    version
    src
    cargoDeps
    ;

  pyproject = true;

  # https://github.com/kevinheavey/solders/blob/0.26.0/pyproject.toml#L42
  dependencies = [
    jsonalias
    python3Packages.typing-extensions
  ];

  nativeBuildInputs = [
    perl
    pkg-config
    maturin
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [ ];

  pythonImportsCheck = [ "solders" ];
}

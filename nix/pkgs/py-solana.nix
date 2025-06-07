{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  solders,
  poetry,
}:
let
  pname = "solana";
  version = "0.36.6";
  src = fetchFromGitHub {
    owner = "michaelhly";
    repo = "solana-py";
    rev = "60f4a041b7378407ecddb41d313da60ff33316c0";
    hash = "sha256-5h4eVTBNaycXDlb+SF1w2CWtlrVpJMqAnHyMMulmH3I=";
  };
in
python3Packages.buildPythonPackage {
  inherit pname version src;
  pyproject = true;
  nativeBuildInputs = [ python3Packages.poetry-core ];
  dependencies =
    [ solders ]
    ++ (with python3Packages; [
      construct-typing
      httpx
      typing-extensions
      websockets
    ]);
}

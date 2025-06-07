{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
let
  version = "1.1.3";
  src = fetchFromGitHub {
    owner = "yuchenlin";
    repo = "rebiber";
    fetchSubmodules = true;
    rev = "v${version}";
    sha256 = "sha256-htf2qy/jIJQKkaPZB/9Yc9OZ1AZrRhpcxzf/G+UWAMY=";
  };
  reqsTxt = lib.readFile "${src}/requirements.txt";
  reqs = lib.splitString "\n" (builtins.replaceStrings [ "==" ] [ "" ] reqsTxt);
in
python3Packages.buildPythonApplication {
  inherit src version;
  pname = "rebiber";
  build-system = [ python3Packages.setuptools ];
  dependencies = map (req: builtins.getAttr (lib.toLower req) python3Packages) reqs;
}

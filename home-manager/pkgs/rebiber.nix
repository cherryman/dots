{
  lib,
  python3,
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
  pythonEnv = python3.withPackages (
    pypkgs: map (req: builtins.getAttr (lib.toLower req) pypkgs) reqs
  );
in
python3.pkgs.buildPythonPackage {
  inherit src version;

  pname = "rebiber";
  format = "setuptools";
  doCheck = false;
  propagatedBuildInputs = [ pythonEnv ];

  installCheckPhase = ''
    rebiber --version > /dev/null
  '';
}

{
  fetchFromGitHub,
  lib,
  pkgs,
  stdenv,
}:
let
  src = fetchFromGitHub {
    owner = "cherryman";
    repo = "cloudflare-ddns";
    rev = "928df05d94e2efdfe4de34fac0e155f5cbe2dc68";
    sha256 = "sha256-5iB7G3heGOAFAcgC0RnFd7H9ZCdmImIEKUwwoW0tcao=";
  };
in
stdenv.mkDerivation {
  inherit src;
  pname = "cfddns";
  version = "0.0.0";
  buildInputs = with pkgs; [
    curl
    dig
    jq
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/cfddns.sh $out/bin/cfddns
  '';
}

{
  fetchFromGitHub,
  lib,
  buildGoModule,
}:
buildGoModule {
  src = fetchFromGitHub {
    owner = "lunchcat";
    repo = "sif";
    rev = "v2024.10.12";
    sha256 = "sha256-b6H4QaNJIqeMyneDl3E28BhEJuGMzGZuYJnBQVYLdQI=";
  };
  pname = "cfddns";
  version = "f8ce014";
  vendorHash = "sha256-tMtisxk7kbJLS4P+sRo9nfSLyQJzTGMzqzNeMDJl0EE=";
}

{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
let
  src = fetchFromGitHub {
    owner = "mpedramfar";
    repo = "zotra-server";
    fetchSubmodules = true;
    rev = "06164a3c169a8ca4f20cec7d0be41d255be8d701";
    sha256 = "sha256-sHyTNuuKZ2TqpdfqJiMLJ3E+ROfR4oTa8nZU5PIFcUg=";
  };
  packageJson = builtins.fromJSON (builtins.readFile "${src}/package.json");
in
buildNpmPackage {
  inherit src;

  pname = packageJson.name;
  version = packageJson.version;
  npmDepsHash = "sha256-b6blHwzNP0vOfqGDMBYmRiD6k9k+YcjVcg0QEKOjgL0";
  makeCacheWritable = true;
  dontNpmBuild = true;

  meta = with lib; {
    description = packageJson.description;
    license = licenses.mit;
  };

  installPhase = ''
    mkdir -p $out/lib/node_modules/zotra
    cp -r . $out/lib/node_modules/zotra
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/zotra/bin/index.js $out/bin/zotra
  '';

  installCheckPhase = ''
    zotra --version > /dev/null
  '';
}

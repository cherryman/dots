{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  makeWrapper,
}:
let
  pname = "rapidraw";
  version = "1.2.5";
  src = fetchFromGitHub {
    owner = "CyberTimon";
    repo = "RapidRAW";
    rev = "v${version}";
    sha256 = "sha256-PZ4z/J28GHBaqttLPrH1Dr+QRcmmRzB/MrHYuE6RYIU=";
  };
in
rustPlatform.buildRustPackage {
  inherit
    pname
    version
    src
    ;

  cargoHash = "sha256-Kv/LjeZb+/DShuYL1psWgzVcJtMLc8LoGabtcSmlt6E=";
  cargoRoot = "./src-tauri";
  buildAndTestSubdir = "./src-tauri";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-MmpjCXHQmYxIXgMJlNsLhRf7fZnEqxWMofugbf9xF84=";
    production = false;
    makeCacheWritable = true;
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    rustPlatform.cargoSetupHook
    makeWrapper
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
    export NPM_CONFIG_CAFILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    npm ci --offline --ignore-scripts
  '';

  buildPhase = ''
    runHook preBuild
    npx --offline tauri build --ci ${if stdenv.isDarwin then "--bundles app" else ""}
    runHook postBuild
  '';

  installPhase =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/bin
      mv src-tauri/target/release/rapidraw $out/bin/
      exit 254 # TODO
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications $out/bin
      mv src-tauri/target/release/bundle/macos/RapidRAW.app $out/Applications/
      makeWrapper $out/Applications/RapidRAW.app/Contents/MacOS/RapidRAW $out/bin/rapidraw
    '';

  meta = with lib; {
    description = "A beautiful, non-destructive, and GPU-accelerated RAW image editor built with performance in mind.";
    homepage = "https://github.com/CyberTimon/RapidRAW";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}

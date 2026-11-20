{
  lib,
  callPackage,
  stdenvNoCC,
  undmg,
}:

# yubico's own signed and notarized macOS build, repackaged as-is.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yubico-authenticator";
  version = "7.4.1";

  src = callPackage ./fetch-verified.nix { } {
    url = "https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-${finalAttrs.version}-mac.dmg";
    hash = "sha256-mtsN6RsTkAPIaQMpbQQgU6ePP2Dq1oOINBvxsbwuHvM=";
    sigHash = "sha256-0SFKNMvbomO65Lly1iQFJ8q7k040ttyJ3SiHZW1Mq3E=";
    key = ./keys/dain-nilsson.asc;
    fingerprint = "20EE325B86A81BCBD3E56798F04367096FBA95E8";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R "Yubico Authenticator.app" $out/Applications/
    runHook postInstall
  '';

  # stripping or patching would invalidate yubico's code signature.
  dontFixup = true;

  meta = {
    description = "Yubico Authenticator for OATH and other YubiKey applications";
    homepage = "https://developers.yubico.com/yubioath-flutter/";
    changelog = "https://github.com/Yubico/yubioath-flutter/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.darwin;
  };
})

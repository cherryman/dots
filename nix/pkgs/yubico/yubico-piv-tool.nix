{
  callPackage,
  yubico-piv-tool,
}:

# nixpkgs' yubico-piv-tool, built from yubico's signed release tarball.
yubico-piv-tool.overrideAttrs (
  finalAttrs: _: {
    version = "2.7.3";

    src = callPackage ./fetch-verified.nix { } {
      url = "https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-${finalAttrs.version}.tar.gz";
      hash = "sha256-/LJcQvVCmOzosgaE+zxYHtkZWhYsvFUYCkFhUBvpMYE=";
      sigHash = "sha256-YEk8dvqbhkgK5o37tKOkG9CmzgNCgqyrk/t3lL8dKJs=";
      key = ./keys/aveen-ismail.asc;
      fingerprint = "1D7308B0055F5AEF36944A8F27A9C24D9588EA0F";
    };
  }
)

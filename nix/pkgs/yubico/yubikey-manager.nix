{
  callPackage,
  yubikey-manager,
}:

# nixpkgs' yubikey-manager, built from yubico's signed release tarball.
yubikey-manager.overridePythonAttrs (old: rec {
  version = "5.9.2";

  src = callPackage ./fetch-verified.nix { } {
    url = "https://developers.yubico.com/yubikey-manager/Releases/yubikey_manager-${version}.tar.gz";
    hash = "sha256-lYTHN3RJ5khxQNpsPxOiieYYsAI8hBS+kcHCEvzjxHM=";
    sigHash = "sha256-OHlu9uI0GaOLhhfPFFCKpo35ook/7OvuQO7qEmzuCc0=";
    key = ./keys/dain-nilsson.asc;
    fingerprint = "20EE325B86A81BCBD3E56798F04367096FBA95E8";
  };

  meta = old.meta // {
    changelog = "https://developers.yubico.com/yubikey-manager/Release_Notes.html";
  };
})

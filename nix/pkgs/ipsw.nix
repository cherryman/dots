{
  fetchFromGitHub,
  lib,
  buildGoModule,
  stdenv,
  darwin,
}:
let
  # watch out for the stale tags! v18..=v29 are >4yr old.
  version = "3.1.591";
in
buildGoModule {
  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    sha256 = "sha256-Y5sUXbRPRtKe8R0rYYfJRfFkbv0W/87KyYJztgcWu5s=";
  };
  inherit version;
  pname = "ipsw";
  vendorHash = "sha256-j7sptEtkbCzztF7D2kW69CKIRPev3kvRHycVq2abeeY";

  subPackages = [
    "cmd/ipsw"
    "cmd/ipswd"
  ];

  # consider using `zig` as `cc` as they do.
  # https://github.com/blacktop/ipsw/blob/675537bd9ea08728fdbce98611acc075411c7972/.goreleaser.yml#L119-L131
}

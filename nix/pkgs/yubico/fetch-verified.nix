{
  fetchurl,
  gnupg,
  runCommand,
}:

# fetch a yubico release artifact and its detached openpgp signature. the
# result is the artifact, but only if the signature verifies against `key`
# and was made by the primary key `fingerprint` (or one of its subkeys).
#
# fingerprints are from:
# https://developers.yubico.com/Software_Projects/Software_Signing.html
#
# keys in ./keys were also cross-checked against yubico's WKD
# (openpgpkey.yubico.com), the signers' github accounts (yubico org members,
# verified @yubico.com emails), and their signed release tags.
{
  url,
  hash,
  sigHash,
  key,
  fingerprint,
}:
let
  file = fetchurl { inherit url hash; };
  sig = fetchurl {
    url = "${url}.sig";
    hash = sigHash;
  };
in
runCommand (baseNameOf url) { nativeBuildInputs = [ gnupg ]; } ''
  export GNUPGHOME=$(mktemp -d)
  gpg --dearmor < ${key} > keyring.gpg

  gpgv --keyring ./keyring.gpg --status-fd 3 ${sig} ${file} 3> status

  # VALIDSIG <signing key fpr> ... <primary key fpr>
  if ! grep -q '^\[GNUPG:\] VALIDSIG .* ${fingerprint}$' status; then
    echo "signature on ${baseNameOf url} not made by ${fingerprint}" >&2
    exit 1
  fi

  cp ${file} $out
''

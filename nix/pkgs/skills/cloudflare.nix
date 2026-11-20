{
  stdenvNoCC,
  fetchFromGitHub,
}:
# agent skills from https://developers.cloudflare.com/agent-setup/
# output layout is `$out/<skill>/SKILL.md`.
stdenvNoCC.mkDerivation {
  pname = "cloudflare-skills";
  version = "0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "skills";
    rev = "cbf893b954222276bf1af57e5f23379231e0efb9";
    hash = "sha256-m/2XzXQ6/gGzeWrdFsnUy7OjHAvKb+a0Q4NjZ868Bdc=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    cp -r skills $out
    runHook postInstall
  '';
}

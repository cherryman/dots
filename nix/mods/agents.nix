{
  lib,
  pkgs,
  ...
}:
let
  cloudflare = pkgs.callPackage ../pkgs/skills/cloudflare.nix { };

  # skill name -> skill directory (containing `SKILL.md`).
  #
  # explicit, since every skill's description ends up in every agent's prompt.
  # merging sets with `//` would let one shadow another, so keep names unique.
  skills = lib.genAttrs [
    "agents-sdk"
    "cloudflare"
    "durable-objects"
    "workers-best-practices"
    "wrangler"
  ] (name: "${cloudflare}/${name}");

  # linked per skill, since the agents keep their own state in these
  # directories (e.g. `~/.codex/skills/.system`).
  skillRoots = [
    ".claude/skills"
    ".codex/skills"
    # antigravity cli (`agy`).
    ".gemini/config/skills"
    # oh-my-pi only reads the other agents' user-level skills when opted in.
    ".omp/agent/skills"
  ];

  skillFiles = lib.concatMap (
    root:
    lib.mapAttrsToList (name: source: lib.nameValuePair "${root}/${name}" { inherit source; }) skills
  ) skillRoots;
in
{
  home.file = lib.listToAttrs skillFiles // {
    ".codex/AGENTS.md".source = ../../AGENTS.md;
    ".claude/CLAUDE.md".source = ../../AGENTS.md;
  };
}

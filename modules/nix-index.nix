{...}:
let
  nixIndexDatabase = builtins.fetchGit {
    url = "https://github.com/nix-community/nix-index-database";
    ref = "refs/tags/2026-07-19-053822";
  };
in
{
  imports = [ "${nixIndexDatabase}/nixos-module.nix" ];

  programs.nix-index-database.enable = true;
}
{ config, lib, pkgs, ... }:
let
  lanzaboote = import (builtins.fetchGit {
    url = "https://github.com/nix-community/lanzaboote";
    ref = "refs/tags/v0.4.2";
  });
in
{

  imports =
    [ lanzaboote.nixosModules.lanzaboote
    ];

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.systemd-boot.configurationLimit = 4;
}
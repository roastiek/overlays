# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/configuration.nix
      ./dev-services.nix
      ../modules/audio.nix
      ../modules/backup.nix
      ../modules/boot-splash.nix
      ../modules/channel.nix
      ../modules/chrome-gnome-shell.nix
      ../modules/desktop.nix
      ../modules/extensions.nix
      ../modules/fonts.nix
      ../modules/games.nix
      ../modules/locales.nix
      ../modules/mypkgs.nix
      ../modules/network-shares.nix
      ../modules/network.nix
      ../modules/nix.nix
      ../modules/printing.nix
      ../modules/secure-boot.nix
      ../modules/snapshots.nix
      ../modules/system-services.nix
      ../modules/users.nix
      ../modules/work-certs.nix
    ];


  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  networking.hostName = "bobo-yoga"; # Define your hostname.

}

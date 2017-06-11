# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common.nix
      ./attwifi
    ];

  nix = {
    #binaryCaches =  [ "http://bobo-laptop:4080/" ];
    #trustedBinaryCaches = [ "http://bobo-laptop:4080/" ];
    #binaryCachePublicKeys = [ "bobo-laptop:uGO5vW8RLbZn0oKYw/0E2YMoIhfnXGlWyJl6XKintmw=" ];
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "bobo-machine"; # Define your hostname.
  networking.extraHosts = ''
    10.0.0.140      bobo-machine.lan bobo-machine
    10.0.0.149      bobo-laptop.lan bobo-laptop
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "networkmanager" "docker" ];
     shell = "/run/current-system/sw/bin/zsh";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  environment.systemPackages = with pkgs; [
    git
    mc
    htop
    firefox
    vivaldi
    vlc
    gnome3.gpaste
    gnome3.gtk
    tango-icon-theme
    tango-extras-icon-theme
    clementine
    opera12
    keepassx
    hostapd
    jdk
    icedtea_web
    enchant
    gnome3.gspell
    hunspell
    hunspellDicts.en-us
    aspellDicts.cs
    aspellDicts.en
    eclipses.eclipse-sdk
    geany
  ];

  services.resolved.enable = false;
  services.nscd.enable = false;
  services.unbound.enable = false;

/*
  systemd.services."sa" = {
    script = "echo service-a";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services."sb" = {
    script = "echo service-b";
    wantedBy = [ "graphical.target" ];
    after = [ "sa.service" ];
    conflicts = [ "sa.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
*/
}

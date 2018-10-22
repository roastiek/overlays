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
    #binaryCaches =  [ "https://cache.nixos.org/" "http://bobo-laptop:4080/" ];
    trustedBinaryCaches = [ "https://cache.nixos.org/" "http://bobo-laptop:4080/" ];
    binaryCachePublicKeys = [ "bobo-laptop:uGO5vW8RLbZn0oKYw/0E2YMoIhfnXGlWyJl6XKintmw=" ];
    useSandbox = false;

/*    buildMachines = [
      { hostName = "localhost";
        maxJobs = 2;
        systems = [ "x86_64-linux" "i686-linux" ];
        supportedFeatures = [ "big-parallel" ];
        speedFactor = 2;
      }
    ];*/
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.consoleLogLevel = 6;

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

  users.extraUsers.lenka = {
     isNormalUser = true;
     uid = 1002;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";

  environment.systemPackages = with pkgs; [
    # sys tools
    bridge-utils
    tcpdump
    hostapd
    xboxdrv
    docker-gc

    # work tools
    git
    mc
    file
    dpkg
    htop
    zip
    unzip
    wget
    tree
    gnumake
    kubectl

    # gui
    firefox
    #vivaldi
    #chromium
    vlc
    mpv
    #gnome3.gpaste
    #gnome3.gtk
    gnome3.gnome-tweak-tool
    tango-icon-theme
    tango-extras-icon-theme
    clementine
    keepassx-community
    streamlink
    eclipses.eclipse-sdk
    geany
    gimp

    # java
    jdk
    icedtea_web

    #enchant
    #gnome3.gspell
    #hunspell
    #hunspellDicts.en-us
    aspellDicts.cs
    aspellDicts.en
    wine
    winetricks
    zoom-us
    steam
    steam-run
  ];

  services.resolved.enable = false;
  services.nscd.enable = false;
  services.unbound.enable = false;

  services.samba = {
    enable = true;
    enableNmbd = true;
    securityType = "user";
    shares = {
      inspiron = {
        path = "/other/backup/inspiron";
        "read only" = "no";
        "valid users" = "lenka";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  virtualisation.docker.enable = true;

  systemd.tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];

  services.hydra = {
    #enable = true;
    hydraURL = "http://bobo-machine/";
    notificationSender = "hydra@hydra.dev";
  };

/*
  systemd.services."sa" = {
    script = "echo service-a";
    wantedBy = [ "multi-user.target" ];
    #wantedBy = [ "basic.target" ];
    #wantedBy = [ "graphical.target" ];
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

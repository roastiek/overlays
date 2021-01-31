# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common.nix
    ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  nix.binaryCaches = [ "https://cache.nixos.org/" "http://hydra.dev.dszn.cz/" ];

  nix.trustedBinaryCaches = [ "https://cache.nixos.org/" "http://hydra.dev.dszn.cz/" ];

  nix.binaryCachePublicKeys = [ "hydra0:AlUk3PBEX4hBeQin6SdNyabXksKhvIfg3wWpmNiQMoc=" ];

  nix.extraOptions = ''
    narinfo-cache-negative-ttl = 300
    http-connections = 100
  '';

  networking.useDHCP = false;
  networking.firewall = with lib; {
    enable = true;
    # allowedUDPPorts = [ 53 ];
    # rejectPackets = true;
  };

  networking.hostName = "bobo-laptop"; # Define your hostname.
  #networking.hosts."10.0.0.149" = [ config.networking.hostName ];
  #networking.hosts."127.0.1.1" = [ ];
  networking.extraHosts = ''
    10.0.0.140      bobo-machine
    10.0.0.139      bobo-laptop
  '';

  networking.resolvconf.extraConfig = ''
    # prepend_nameservers=192.168.121.1
    # prepend_search=lan
    append_search="dev.dszn.cz test.dszn.cz dszn.cz"
  '';

  virtualisation.lxd.enable = true;

  environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".text = ''
    server=/lxd/172.18.0.1
    rev-server=172.18.0.0/16,172.18.0.1
    # rev-server=fd42:52bb:7b8c:d18e::0/64,172.18.0.1
    # log-queries
    # dns-loop-detect
  '';

  virtualisation.docker.enable = true;

  # services.nscd.enable = false;

  services.nix-serve = {
    enable = true;
    port = 4080;
    secretKeyFile = "/etc/nix-serve/nix-serve.key";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # systools
    tcpdump
    bridge-utils
    tunctl
    iptables
    debootstrap
    lxc-templates

    # work tools
    git
    mc
    htop
    dpkg
    zip
    unzip
    kubectl
    gnumake
    tree
    wget
    file
    #gocode
    #godef
    #gotools
    jq
    direnv
    goenvtemplator

    firefox
    vlc
    mpv
    #gnome3.gpaste
    gnome3.gnome-tweak-tool
    #gnome3.gtk
    tango-icon-theme
    tango-extras-icon-theme
    #pidgin
    geany
    clementine
    opera12
    keepassx-community
    #jre
    jdk
    icedtea_web
    gnupg1
    openssl
    #enchant
    #gnome3.gspell
    #hunspell
    #hunspellDicts.en-us
    #aspell
    aspellDicts.cs
    aspellDicts.en
    libreoffice
    # eclipses.eclipse-sdk
    #yed
    streamlink
    gimp
    wine
    winetricks
    zoom-us
    plex-media-player
    kid3
    picard
    atomicparsley
    minetime

    ( vscode-with-extensions )
    vscodium

    virtualgl
    xorg.xhost

    i7z
    ethtool
    powertop
    sysbench
    intel-undervolt
    thermald
    gnome3.dconf-editor
    synergy
    barrier
    cifs-utils
  ];

  systemd.services.NetworkManager.restartTriggers = [ config.environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".source ];
  systemd.services.NetworkManager.reloadIfChanged = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     shell = "/run/current-system/sw/bin/zsh";
     extraGroups = [ "wheel" "networkmanager" "docker" "lxd" ];
  };

  hardware.pulseaudio.package = pkgs.pulseaudio99Full;

  # The NixOS release to be compatible with for stateful data such as databases.
  # system.stateVersion = "20.03";

  # system.nixos.revision = "20.03";

}

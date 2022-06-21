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

  #boot.kernel.sysctl = {
  #  "net.ipv4.conf.all.forwarding" = 1;
  #  "net.ipv4.ip_forward" = 1;
  #};

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
  };

  networking.hostName = "bobo-laptop"; # Define your hostname.
  networking.extraHosts = ''
    10.0.0.140      bobo-machine
    10.0.0.141      bobo-laptop
    10.0.0.142      bobo-inspiron
  '';

  networking.resolvconf.extraConfig = ''
    # prepend_nameservers=192.168.121.1
    # prepend_search=lan
    append_search="dev.dszn.cz test.dszn.cz dszn.cz"
  '';

  #virtualisation.lxd.enable = true;
  #environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".text = ''
  #  server=/lxd/172.18.0.1
  #  rev-server=172.18.0.0/16,172.18.0.1
  #  # rev-server=fd42:52bb:7b8c:d18e::0/64,172.18.0.1
  #  # log-queries
  #  # dns-loop-detect
  #'';
  #systemd.services.NetworkManager.restartTriggers = [ config.environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".source ];
  systemd.services.NetworkManager.reloadIfChanged = true;

  virtualisation.podman.enable = true;

  virtualisation.docker.enable = true;

  services.xserver.displayManager.defaultSession = "gnome";

  services.nix-serve = {
    enable = true;
    port = 4080;
    secretKeyFile = "/etc/nix-serve/nix-serve.key";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';

  services.fwupd.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # systools
    tunctl
    iptables
    debootstrap
    lxc-templates
    i7z
    ethtool
    powertop
    intel-undervolt
    thermald
    thermal-monitor
    config.boot.kernelPackages.cpupower
    #qsync

    # work tools
    goenvtemplator
    kube-login
    whois
    maven
    vw

    gnupg1
    openssl
    #binance

    arc-theme
    adwaita-qt
    arc-kde-theme
    matcha-gtk-theme
    qogir-theme
    theme-jade1
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bobo = {
    isNormalUser = true;
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" "docker" "lxd" "power" ]; # Enable ‘sudo’ for the user.
  };

}

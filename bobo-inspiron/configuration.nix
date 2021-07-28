# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common.nix
      # ./k8s.nix
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

  virtualisation.podman.enable = true;

  environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".text = ''
    server=/lxd/172.18.0.1
    rev-server=172.18.0.0/16,172.18.0.1
    # rev-server=fd42:52bb:7b8c:d18e::0/64,172.18.0.1
    # log-queries
    # dns-loop-detect
  '';

  virtualisation.docker.enable = true;

  # services.nscd.enable = false;

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

  environment.systemPackages = with pkgs; [
    # systools
    tunctl
    iptables
    debootstrap
    lxc-templates
    i7z
    ethtool
    powertop
    sysbench
    intel-undervolt
    thermald

    # work tools
    goenvtemplator
    kube-login
    whois
    maven
    vw
    #gocode
    #godef
    #gotools
    #bubblewrap

    gnupg1
    openssl

    arc-theme
    adwaita-qt
    arc-kde-theme
    matcha-gtk-theme
    qogir-theme
    theme-jade1
  ];

  systemd.services.NetworkManager.restartTriggers = [ config.environment.etc."NetworkManager/dnsmasq.d/50-lxd.conf".source ];
  systemd.services.NetworkManager.reloadIfChanged = true;

  services.earlyoom.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     shell = "/run/current-system/sw/bin/zsh";
     extraGroups = [ "wheel" "networkmanager" "docker" "lxd" ];
  };

  services.restic.backups = {
    home = {
      initialize = true;
      repository = "sftp:admin@ruster:/share/Backups/2in1/homes";

      rcloneOptions = {
        "sftp-key-file" = "/etc/restic/ruster_id_rsa";
      };

      paths = [ "/home" ];

      extraBackupArgs = [
        "--one-file-system"
        "--exclude" "Music"
        "--exclude-caches"
        #"--exclude-larger-than" "1G"
      ];

      passwordFile = "/etc/restic/ruster_home.pass";

      extraOptions = [
        "sftp.command='ssh admin@ruster -i /etc/restic/ruster_id_rsa -s sftp'"
      ];
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  # system.stateVersion = "20.03";

  # system.nixos.revision = "20.03";

}

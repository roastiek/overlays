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

#  nix = {
#    # binaryCaches =  [ "https://cache.nixos.org/" "http://bobo-laptop:4080/" ];
#    trustedBinaryCaches = [ "https://cache.nixos.org/" "http://bobo-laptop:4080/" ];
#    binaryCachePublicKeys = [ "bobo-laptop:uGO5vW8RLbZn0oKYw/0E2YMoIhfnXGlWyJl6XKintmw=" ];
#    useSandbox = false;

#/*    buildMachines = [
#      { hostName = "localhost";
#        maxJobs = 2;
#        systems = [ "x86_64-linux" "i686-linux" ];
#        supportedFeatures = [ "big-parallel" ];
#        speedFactor = 2;
#      }
#    ];*/
#  };

  boot.consoleLogLevel = 6;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  networking.useDHCP = false;
  networking.hostName = "bobo-machine"; # Define your hostname.
  networking.extraHosts = ''
    10.0.0.140      bobo-machine.lan bobo-machine
    10.0.0.141      bobo-laptop.lan bobo-laptop
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "networkmanager" "docker" ];
     shell = "/run/current-system/sw/bin/zsh";
  };

  #users.extraUsers.lenka = {
  #   isNormalUser = true;
  #   uid = 1002;
  #};

  # The NixOS release to be compatible with for stateful data such as databases.
  # system.stateVersion = "20.09";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.cpupower
    ( dwarf-fortress-packages.dwarf-fortress-full.override {
      #dfVersion = "0.44.11";
      #theme = "cla";
      enableIntro = false;
      enableFPS = true;
      enableSound = false;
      enableTWBT = true;
    } )
  ];

  services.resolved.enable = false;
  services.unbound.enable = false;

  services.samba = {
    enable = false;
    enableNmbd = true;
    #securityType = "user";
    #shares = {
    #  inspiron = {
    #    path = "/other/backup/inspiron";
    #    "read only" = "no";
    #    "valid users" = "lenka";
    #  };
    #  bobo = {
    #    path = "/home/bobo";
    #    "read only" = "no";
    #    "valid users" = "bobo";
    #  };
    #};
  };

  # networking.firewall.allowedTCPPorts = [ 139 445 ];
  # networking.firewall.allowedUDPPorts = [ 137 138 53 ];

  #networking.nat ={
  #  enable = true;
  #  externalInterface = "tun0";
  #  internalInterfaces = [ "enp2s0" ];
  #};

  # virtualisation.docker.enable = true;

  # systemd.tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];

  services.hydra = {
    #enable = true;
    hydraURL = "http://bobo-machine/";
    notificationSender = "hydra@hydra.dev";
  };

  services.dnsmasq = {
    enable = false;
    resolveLocalQueries = false;
    extraConfig = ''
      server=127.0.0.1
      no-resolv
      no-hosts
      no-negcache
      except-interface=lo
      bind-dynamic
    '';
  };

  # services.earlyoom.enable = true;

  # environment.etc."iscsi/initiatorname.iscsi".text = ''
  #   InitiatorName=iqn.2016-04.com.open-iscsi:bobo-machine
  # '';

  # systemd.packages = [ pkgs.openiscsi ];

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

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let

  flushNat = ''
    iptables -w -t nat -D POSTROUTING -s 192.168.121.0/24 -d 224.0.0.0/24 -j RETURN || true
    iptables -w -t nat -D POSTROUTING -s 192.168.121.0/24 -d 255.255.255.255/32 -j RETURN || true
    iptables -w -t nat -D POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535 || true
    iptables -w -t nat -D POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -p udp -j MASQUERADE --to-ports 1024-65535 || true
    iptables -w -t nat -D POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -j MASQUERADE || true

    iptables -w -t mangle -D POSTROUTING -o lxcbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill || true

    iptables -w -D INPUT -i lxcbr0 -p udp -m udp --dport 53 -j ACCEPT || true
    iptables -w -D INPUT -i lxcbr0 -p tcp -m tcp --dport 53 -j ACCEPT || true
    iptables -w -D INPUT -i lxcbr0 -p udp -m udp --dport 67 -j ACCEPT || true
    iptables -w -D INPUT -i lxcbr0 -p tcp -m tcp --dport 67 -j ACCEPT || true
    iptables -w -D INPUT -i docker0 -p udp -m udp --dport 53 -j ACCEPT || true
    iptables -w -D INPUT -i docker0 -p tcp -m tcp --dport 53 -j ACCEPT || true

    iptables -D FORWARD -d 192.168.121.0/24 -o lxcbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
    iptables -D FORWARD -s 192.168.121.0/24 -i lxcbr0 -j ACCEPT || true
    iptables -D FORWARD -i lxcbr0 -o lxcbr0 -j ACCEPT || true
    iptables -D FORWARD -i docker0 -o lxcbr0 -j ACCEPT || true
    iptables -D FORWARD -i docker0 -o docker -j ACCEPT || true
    iptables -D FORWARD -o lxcbr0 -j REJECT --reject-with icmp-port-unreachable || true
    iptables -D FORWARD -i lxcbr0 -j REJECT --reject-with icmp-port-unreachable || true
  '';

  setupNat = ''
    iptables -w -t nat -A POSTROUTING -s 192.168.121.0/24 -d 224.0.0.0/24 -j RETURN
    iptables -w -t nat -A POSTROUTING -s 192.168.121.0/24 -d 255.255.255.255/32 -j RETURN
    iptables -w -t nat -A POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
    iptables -w -t nat -A POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
    iptables -w -t nat -A POSTROUTING -s 192.168.121.0/24 ! -d 192.168.121.0/24 -j MASQUERADE

    iptables -w -t mangle -A POSTROUTING -o lxcbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill

    iptables -w -A INPUT -i lxcbr0 -p udp -m udp --dport 53 -j ACCEPT
    iptables -w -A INPUT -i lxcbr0 -p tcp -m tcp --dport 53 -j ACCEPT
    iptables -w -A INPUT -i lxcbr0 -p udp -m udp --dport 67 -j ACCEPT
    iptables -w -A INPUT -i lxcbr0 -p tcp -m tcp --dport 67 -j ACCEPT
    iptables -w -A INPUT -i docker0 -p udp -m udp --dport 53 -j ACCEPT
    iptables -w -A INPUT -i docker0 -p tcp -m tcp --dport 53 -j ACCEPT

    iptables -A FORWARD -d 192.168.121.0/24 -o lxcbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -s 192.168.121.0/24 -i lxcbr0 -j ACCEPT
    iptables -A FORWARD -i lxcbr0 -o lxcbr0 -j ACCEPT
    iptables -A FORWARD -i docker0 -o lxcbr0 -j ACCEPT
    iptables -A FORWARD -i docker0 -o docker -j ACCEPT
    iptables -A FORWARD -o lxcbr0 -j REJECT --reject-with icmp-port-unreachable
    iptables -A FORWARD -i lxcbr0 -j REJECT --reject-with icmp-port-unreachable
  '';

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/common.nix
    ];


  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.efiBootloaderId = "NixOS";
  # boot.kernelPackages = pkgs.linuxPackages_4_8;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

#  nix.binaryCaches = [
#    "http://szn-nix-cache.s3-eu-central-1.amazonaws.com"
#  ];

  nix.binaryCachePublicKeys = [ "hydra.szn:s5RJc+u3wLOO/0+svaLaB8rG34Ok4C8kanIOPH6KQ5U=" ];

#  nixpkgs.config.wine = {
#    build = "wine32";
#  };

  networking.firewall = with lib; {
    enable = true;
    extraCommands = mkMerge [ (mkBefore flushNat) setupNat ];
    extraStopCommands = flushNat;
  };

  networking.hostName = "bobo-laptop"; # Define your hostname.
  networking.extraHosts = ''
    10.0.0.140      bobo-machine.lan bobo-machine
    10.0.0.149      bobo-laptop.lan bobo-laptop
  '';

  networking.networkmanager.unmanaged = [
    "interface-name:lxcbr*" "interface-name:veth*"
  ];

  networking.bridges.lxcbr0 = {
    interfaces = [ "lxcbr0-nic" ];
  };
  networking.interfaces.lxcbr0 = {
    ipv4.addresses = [ { address = "192.168.121.1"; prefixLength=24; }];
  };
  networking.interfaces.lxcbr0-nic = {
    virtual = true;
    virtualType = "tap";
    useDHCP = false;
  };

  networking.nat = {
    enable = false;
    externalInterface = "enp0s31f6";
    internalInterfaces = [ "lxcbr0" ];
  };

  virtualisation.lxc = {
    enable  = true;
    defaultConfig = ''
      lxc.network.type = veth
      lxc.network.link = lxcbr0
    '';
  };

  virtualisation.docker.enable = true;

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      server=127.0.0.1
      no-resolv
      auth-zone=lan
      dhcp-range=192.168.121.100,192.168.121.150
      dhcp-no-override
      dhcp-option=option:domain-name,lan
      bind-dynamic
      #interface=lxcbr0
      listen-address=192.168.121.1

      enable-ra
      #dhcp-range=::100,::1ff,constructor:lxcbr0

      log-dhcp
      log-queries
    '';
  };

  services.nscd.enable = false;

  networking.resolvconfOptions = [ "ndots:2" ];

  networking.extraResolvconfConf = ''
    prepend_nameservers=192.168.121.1
    prepend_search=lan
    append_search="dev.dszn.cz test.dszn.cz dszn.cz"
  '';

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
    kubernetes
    gnumake
    tree
    wget
    file
    gocode
    godef
    gotools
    jq

    firefox
    vlc
    mpv
    gnome3.gpaste
    gnome3.gnome-tweak-tool
    gnome3.gtk
    tango-icon-theme
    tango-extras-icon-theme
    pidgin
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
    eclipses.eclipse-sdk
    yed
    streamlink
    gimp
    wine
    winetricks
    zoom-us
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     shell = "/run/current-system/sw/bin/zsh";
     extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";

  #systemd.services."systemd-backlight@".enable = false;
  systemd.services.fstrim.preStart = ''
    ${pkgs.utillinux.bin}/bin/fstrim -v /
  '';
}

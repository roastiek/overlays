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

    iptables -D FORWARD -d 192.168.121.0/24 -o lxcbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
    iptables -D FORWARD -s 192.168.121.0/24 -i lxcbr0 -j ACCEPT || true
    iptables -D FORWARD -i lxcbr0 -o lxcbr0 -j ACCEPT || true
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

    iptables -A FORWARD -d 192.168.121.0/24 -o lxcbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -s 192.168.121.0/24 -i lxcbr0 -j ACCEPT
    iptables -A FORWARD -i lxcbr0 -o lxcbr0 -j ACCEPT
    iptables -A FORWARD -o lxcbr0 -j REJECT --reject-with icmp-port-unreachable
    iptables -A FORWARD -i lxcbr0 -j REJECT --reject-with icmp-port-unreachable
  '';

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  nix = {
    # nixPath = [ "/etc/nixos" "nixos-config=/etc/nixos/configuration.nix" ];
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.efiBootloaderId = "NixOS";
  #boot.kernelPackages = pkgs.linuxPackages_4_8;
  boot.kernelParams = [ "systemd.restore_state=0" ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  networking.firewall = with lib; {
    enable = true;
    extraCommands = mkMerge [ (mkBefore flushNat) setupNat ];
    extraStopCommands = flushNat;
    allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];
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
    ip4 = [ { address = "192.168.121.1"; prefixLength=24; }];
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

  # networking.wireless.enable = true;  # Enables wireless  support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = with pkgs; [
  #   wget
  # ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
  ];

  programs.bash.enableCompletion = true;

  programs.zsh.enable = true;
  environment.etc."profile.local".text = "export __ETC_ZSHENV_SOURCED=1";

  virtualisation.lxc = {
    enable  = true;
    defaultConfig = ''
      lxc.network.type = veth
      lxc.network.link = lxcbr0
    '';
  };

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
    '';
  };

  networking.extraResolvconfConf = ''
    prepend_nameservers=192.168.121.1
    prepend_search=lan
  '';

  services.nix-serve = {
    enable = true;
    port = 4080;
    secretKeyFile = "/etc/nix-serve/nix-serve.key";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.desktopManager.gnome3.sessionPath = [ pkgs.gnome3.gpaste ];
  systemd.packages = with pkgs; [ gnome3.gpaste ];

  environment.systemPackages = with pkgs; [
    git
    mc
    htop
    firefox
    vivaldi
    vlc
    gnome3.gpaste
    gnome3.gnome-tweak-tool
    gnome3.gtk
    tango-icon-theme
    tango-extras-icon-theme
    pidgin
    geany
    clementine
    opera12
    keepassx
    #jre
    jdk
    icedtea_web
    debootstrap
    wget
    gnupg1
    openssl
    tcpdump
    bridge-utils
    tunctl
    iptables
    enchant
    gnome3.gspell
    #hunspell
    #hunspellDicts.en-us
    #aspell
    aspellDicts.cs
    aspellDicts.en
    libreoffice
    eclipses.eclipse-sdk
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    freetype_subpixel = pkgs.freetype.override {
      useEncumberedCode = true;
      useInfinality = false;
    };
  };

  fonts = {
    enableDefaultFonts = false;
    enableFontDir = true;
    fonts = with pkgs; [ 
      #(pkgs.callPackage ./liberation-fonts1 {})
      liberation1_ttf
      freefont_ttf
    ];
    fontconfig.ultimate.enable = false;
    fontconfig.ultimate.preset = "ultimate1";
  };

  system.replaceRuntimeDependencies = with pkgs; [
    ({ original = dnsmasq;
       replacement = pkgs.dnsmasq.overrideDerivation (oldAttrs: rec {
         version = "2.77test4";
         src = fetchurl {
           url = "https://github.com/imp/dnsmasq/archive/v2.77test4.tar.gz";
           sha256 = "1qq2nm7q4mmm04k47yq5xvyallgrrx67s25c3njc24d9byxki8nm";
         };
       }); })
    { original = freetype;
       replacement = freetype_subpixel; }
    { original = aspell;
       replacement = aspellDictDir; }
    { original = qt48;
       replacement = qt48gtk; }
    { original = gnome3.evolution_data_server;
       replacement = gnome3.evolution_data_server_ids; }
  ];

  nixpkgs.overlays = [ ( import ../mypkgs ) ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    icedtea = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     shell = "/run/current-system/sw/bin/zsh";
     extraGroups = [ "wheel" "networkmanager" ];
  };


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  #systemd.services."systemd-backlight@".enable = false;
}

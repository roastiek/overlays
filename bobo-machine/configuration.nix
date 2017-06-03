# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./attwifi
    ];

  nix = {
    #nixPath = [ "/etc/nixos" "nixos-config=/etc/nixos/configuration.nix" ];
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
    #binaryCaches =  [ "http://bobo-laptop:4080/" ];
    #trustedBinaryCaches = [ "http://bobo-laptop:4080/" ];
    #binaryCachePublicKeys = [ "bobo-laptop:uGO5vW8RLbZn0oKYw/0E2YMoIhfnXGlWyJl6XKintmw=" ];
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/disk/by-id/ata-SanDisk_Ultra_II_960GB_163801800068"; # or "nodev" for efi only

  networking.hostName = "bobo-machine"; # Define your hostname.
  networking.extraHosts = ''
    10.0.0.140      bobo-machine.lan bobo-machine
    10.0.0.149      bobo-laptop.lan bobo-laptop
    #10.0.133.71     benes-rostislav.brno.seznam.cz
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.buildCores = 3;

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

  programs.zsh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  # boot.initrd.kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_modeset" "nvidia_drm" ];
  # boot.kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_modeset" "nvidia_drm" ];
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.debug = false;

  services.xserver.desktopManager.gnome3 = {
    enable = true;
    sessionPath = [ pkgs.gnome3.gpaste ];
  };
  services.gnome3.evolution-data-server.plugins = with pkgs; [ gnome3.evolution-rss ];
  services.xserver.desktopManager.default = "gnome3";
  # systemd.targets."graphical".conflicts = [ "getty@tty1.service" ];

  # systemd.targets."getty".unitConfig.X-StopOnReconfiguration=true;

  services.journald.rateLimitInterval = "0";

  # services.xserver.displayManager.xserverArgs = [ "-novtswitch" ]; 
  # services.xserver.display = lib.mkForce 0;
  # services.xserver.tty = lib.mkForce 7;

  services.postgresql.enable = false;
  services.hydra = {
    enable = false;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
  };

#  nix.buildMachines = [
#    {
#      hostName = "localhost";
#      systems = [ "x86_64-linux" ];
#      maxJobs = 1;
#      supportedFeatures = [ "kvm" "nixos-test" ];
#    }
#  ];

  #nixpkgs.config.packageOverrides = pkgs: {
  #  freetype_subpixel = pkgs.freetype.override {
  #    useEncumberedCode = true;
  #    useInfinality = false;
  #  };
  #};

  hardware.opengl.extraPackages = [ pkgs.libvdpau-va-gl pkgs.libvdpau ];
  hardware.opengl.extraPackages32 = [ pkgs.libvdpau-va-gl ];
  hardware.opengl.driSupport32Bit = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bobo = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "networkmanager" "docker" ];
     shell = "/run/current-system/sw/bin/zsh";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  system.replaceRuntimeDependencies = with pkgs; [
    { original = dnsmasq;
      replacement = pkgs.dnsmasq.overrideDerivation (oldAttrs: rec {
        version = "2.77test4";
        src = fetchurl {
          url = "https://github.com/imp/dnsmasq/archive/v2.77test4.tar.gz";
          sha256 = "1qq2nm7q4mmm04k47yq5xvyallgrrx67s25c3njc24d9byxki8nm";
        };
      });
    }
    { original = freetype;
      replacement = freetype_subpixel;
    }
    { original = qt48;
      replacement = qt48gtk;
    }
    ({ original = aspell;
       replacement = aspellDictDir; })
    ({ original = gnome3.evolution_data_server;
       replacement = gnome3.evolution_data_server_ids; })
  ];

  nixpkgs.overlays = [ ( import ../mypkgs) ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    icedtea = true;
  };
  #nixpkgs.config.permittedInsecurePackages = [
  #  "webkitgtk-2.4.11"
  #];

  networking.firewall.allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];

  systemd.packages = with pkgs; [ gnome3.gpaste ];

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
    jre
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
    chrome-gnome-shell
  ];

  fonts = {
    enableDefaultFonts = false;
    enableFontDir = true;
    fonts = with pkgs; [ 
      liberation1_ttf
      freefont_ttf
    ];
    fontconfig.ultimate.enable = false;
    fontconfig.ultimate.preset = "ultimate1";
  };

  hardware.pulseaudio.extraConfig = ''
    set-sink-port alsa_output.pci-0000_00_1b.0.analog-stereo analog-output-headphones
    set-sink-mute alsa_output.pci-0000_00_1b.0.analog-stereo 0
  '';

  environment.etc."profile.local".text = "export __ETC_ZSHENV_SOURCED=1";

  networking.networkmanager.unmanaged = [ "mac:00:0e:2e:f1:3c:cf" "interface-name:attwifi" ];
  networking.usePredictableInterfaceNames = false;

  virtualisation.docker = {
    enable = false;
    storageDriver = "btrfs";
  };

  virtualisation.lxc.enable = false;

  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
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

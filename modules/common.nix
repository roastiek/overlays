{ config, pkgs, lib, ... }:
{
  imports = [
    ./channel.nix
    ./chrome-gnome-shell.nix
    ./extensions.nix
    ./basic-apps.nix
    ./thermald.nix
  ];

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      trusted-users = [ "@wheel" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      keep-env-derivations = true
      experimental-features = nix-command
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d --max-freed $((64 * 1024**3))";
      persistent = true;
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  systemd.services.nix-gc.serviceConfig.Type = "oneshot";

  systemd.timers.nix-optimise.timerConfig.Persistent = true;
  systemd.services.nix-optimise = {
    serviceConfig.Type = "oneshot";
    after = [ "nix-gc.service" ];
  };

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "cs_CZ.UTF-8/UTF-8" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  networking.firewall.allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];
  networking.networkmanager.dns = "dnsmasq";
  networking.networkmanager.extraConfig = ''
    [main]
    systemd-resolved=false
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # services.openssh.forwardX11 = true;
  # programs.ssh.setXAuthLocation = true;

  programs.command-not-found.enable = true;
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.defaultSession = lib.mkDefault "gnome";
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome3.gpaste pkgs.gnome3.mutter ];

  services.gnome.evolution-data-server.enable = true;
  programs.evolution.enable = true;

  programs.gpaste.enable = true;

  # services.usbguard.enable = true;
  # #services.usbguard.implictPolicyTarget = "allow";
  # #services.usbguard.presentDevicePolicy = "keep";
  # services.usbguard.IPCAllowedGroups = [ "wheel" ];
  # systemd.services.usbguard-dbus = {
  #   requires = [ "usbguard.service" ];
  #   description =  "USBGuard D-Bus Service";
  #   documentation = [ "man:usbguard-dbus(8)" ];
  #   serviceConfig = {
  #     Type = "dbus";
  #     BusName = "org.usbguard1";
  #     ExecStart="${config.services.usbguard.package}/bin/usbguard-dbus --system";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  #   aliases = [ "dbus-org.usbguard.service" ];
  # };

  # systemd.services.usbguard = {
  #   serviceConfig = {
  #     DevicePolicy = lib.mkForce "closed";
  #     ReadWritePaths = lib.mkForce "-/dev/shm -/tmp -/var/lib/usbguard -/etc/usbgurad";
  #   };
  # };

  services.journald.rateLimitInterval = "0";

  services.fstrim.enable = true;
  systemd.services.fstrim.after = [ "nix-optimise.service" ];

  services.snapper = {
    snapshotInterval = "*-*-* *:0/15:00";
    cleanupInterval = "1h";
    configs = {
      home = {
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = "28800";
        TIMELINE_LIMIT_HOURLY = "0-48";
        TIMELINE_LIMIT_DAILY = "0-14";
        TIMELINE_LIMIT_WEEKLY = "0-8";
        TIMELINE_LIMIT_MONTHLY = "0-3";
        TIMELINE_LIMIT_YEARLY = "0-2";
        SYNC_ACL = "yes";
      };
    };
  };

  systemd.services."save-hwclock".wantedBy = lib.mkForce [];

  fonts = {
    enableDefaultFonts = false;
    #enableFontDir = true;
    #enableCoreFonts = true;
    fonts = with pkgs; [
      liberation_ttf_v1
      #liberation_ttf
      freefont_ttf
      #gyre-fonts # TrueType substitutes for standard PostScript fonts
      unifont
    ];
    #fontconfig.penultimate.enable = false;
  };

  environment.extraInit = ''
    export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
  '';

  system.replaceRuntimeDependencies = with pkgs; [
  #  { original = freetype;
  #    replacement = freetype29;
  #  }
  ];

  nixpkgs.overlays = [ ( import ../mypkgs ) ];
  nixpkgs.config.allowUnfree = true;

  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-issuing.crt
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
    ./cert/seznam-kancelar-root-ca-2020.crt
    ./cert/seznam-kancelar-issuing-ca-2021.crt
    ./cert/seznam-rootca-2022.crt
  ];

  virtualisation.docker = {
    autoPrune.enable = true;
    autoPrune.flags = [ "--volumes" ];
  };

  systemd.timers.docker-prune.timerConfig.Persistent = true;
  systemd.services.docker-prune.before = [ "nix-gc.service" ];

  hardware.pulseaudio.enable = false;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
  # hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  # hardware.pulseaudio.extraConfig = ''
  #   load-module module-switch-on-connect
  # '';

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  security.rtkit.enable = true;

  fileSystems."/remote/amour" =
    { device = "ruster:/Amour";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };

  fileSystems."/remote/music" =
    { device = "ruster:/Music";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };

  fileSystems."/remote/download" =
    { device = "ruster:/Download";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };
}

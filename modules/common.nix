{ config, pkgs, lib, ... }:
{
  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
      env-keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d --max-freed $((64 * 1024**3))";
    };
  };

  systemd.timers."nix-gc".timerConfig.Persistent = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  networking.firewall.allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];
  networking.networkmanager.dns = "dnsmasq";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  programs.command-not-found.enable = true;
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  environment.etc."profile.local".text = "export __ETC_ZSHENV_SOURCED=1";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;


  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.gnome3 = {
    enable = true;
    sessionPath = [ pkgs.chrome-gnome-shell ];
  };
  services.gnome3.gpaste.enable = true;

  #services.gnome3.evolution-data-server.plugins = with pkgs; [ gnome3.evolution-rss ];

  systemd.packages = [ pkgs.chrome-gnome-shell ];
  environment.systemPackages = [ pkgs.chrome-gnome-shell pkgs.volume-mixer ];
  services.dbus.packages = [ pkgs.chrome-gnome-shell ];
  environment.etc."chromium/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source = "${pkgs.chrome-gnome-shell}/etc/chromium/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";
  environment.etc."opt/chrome/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source = "${pkgs.chrome-gnome-shell}/etc/opt/chrome/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  services.journald.rateLimitInterval = "0";

  services.fstrim.enable = true;
  systemd.services.fstrim.after = [ "nix-gc.service" ];

  services.snapper = {
    snapshotInterval = "*-*-* *:0/15:00";
    cleanupInterval = "1h";
    configs = {
      home = {
        subvolume = "/home";
        extraConfig = ''
          TIMELINE_CREATE="yes"
          TIMELINE_CLEANUP="yes"
          TIMELINE_MIN_AGE="28800"
          TIMELINE_LIMIT_HOURLY="8-48"
          TIMELINE_LIMIT_DAILY="2-14"
          TIMELINE_LIMIT_WEEKLY="1-8"
          TIMELINE_LIMIT_MONTHLY="1-3"
          TIMELINE_LIMIT_YEARLY="0"
          SYNC_ACL="yes"
        '';
      };
    };
  };

  systemd.services."save-hwclock".wantedBy = lib.mkForce [];

  fonts = {
    enableDefaultFonts = false;
    #enableFontDir = true;
    #enableCoreFonts = true;
    fonts = with pkgs; [
      liberation_ttf_v1_binary
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
  #    replacement = freetype_subpixel;
  #  }
    #{ original = aspell;
    #  replacement = aspellDictDir;
    #}
    { original = openjdk8;
      replacement = openjdk8_clean;
    }
    #{ original = gnome3.evolution_data_server;
    #  replacement = gnome3.evolution_data_server_ids;
    #}
  ];

  nixpkgs.overlays = [ ( import ../mypkgs) ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox = {
    enableAdobeFlash = false;
    enableGnomeExtensions = true;
    icedtea = true;
  };

  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
  ];

  virtualisation.docker = {
    autoPrune.enable = true;
    autoPrune.flags = [ "--volumes" ];
  };

}

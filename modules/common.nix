{ config, pkgs, lib, ... }:

{

  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
    gc = {
      automatic = true;
      dates = "daily";
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  programs.bash.enableCompletion = true;

  programs.zsh.enable = true;
  environment.etc."profile.local".text = "export __ETC_ZSHENV_SOURCED=1";

  #systemd.services."systemd-vconsole-setup".enable = false;
  systemd.services."systemd-vconsole-setup".wantedBy = lib.mkForce [];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.default = "gnome3";
  services.xserver.desktopManager.gnome3 = {
    enable = true;
    sessionPath = [ pkgs.gnome3.gpaste ];
  };
  systemd.packages = with pkgs; [ gnome3.gpaste utillinuxServices.bin ];

  services.gnome3.evolution-data-server.plugins = with pkgs; [ gnome3.evolution-rss ];

  services.journald.rateLimitInterval = "0";

  systemd.timers.fstrim.wantedBy = [ "timers.target" ];

  systemd.services."save-hwclock".wantedBy = lib.mkForce [];

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
    { original = aspell;
      replacement = aspellDictDir;
    }
    { original = openjdk8;
      replacement = openjdk8_clean;
    }
    { original = gnome3.evolution_data_server;
      replacement = gnome3.evolution_data_server_ids;
    }
  ];

  nixpkgs.overlays = [ ( import ../mypkgs) ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    icedtea = true;
  };

  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
  ];

}

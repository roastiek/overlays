{ config, lib, pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; lib.mkForce [
      #liberation_ttf_v1
      font-awesome
      openmoji-black
      ankacoder
      inconsolata
      iosevka
      maple-mono.opentype
      liberation_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      unifont
      # noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      serif = [ "Liberation Serif" ];
      sansSerif = [ "Liberation Sans" ];
      monospace = [ "Liberation Mono" ];
    };
    fontconfig = {
      hinting.style = "full";
      # hinting.style = "none";
      subpixel.rgba = "rgb";
      # subpixel.rgba = "none";
      # subpixel.lcdfilter = "light";
      subpixel.lcdfilter = "default";
      allowBitmaps = false;
    };
    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <rejectfont>
          <glob>${pkgs.dejavu_fonts.minimal}/*</glob>
        </rejectfont>
      </fontconfig>
    '';
  };

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    font-rendering='manual'
  '';

  environment.etc."xdg/gtk-4.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-font-rendering=manual
      gtk-hint-font-metrics=1
    '';
  };

  environment.extraInit = ''
    export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
  '';
}
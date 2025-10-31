{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gpaste pkgs.mutter pkgs.gnome-settings-daemon ];
  services.xserver.desktopManager.gnome.sessionPath = [ pkgs.gnome-browser-connector ];

  services.displayManager.defaultSession = lib.mkDefault "gnome";

  services.gnome.gnome-browser-connector.enable = true;

  programs.gpaste.enable = true;

  programs.firefox.enable = true;
  programs.gnome-terminal.enable = true;

  environment.systemPackages = with pkgs; [
    zenity
    gnome-tweaks
    tango-icon-theme
    tango-extras-icon-theme
    keepassxc
    dconf-editor
    vivaldi
    picard
    gimp
    vlc
    clementine
    strawberry
    libreoffice
    viewnior
  ];

}

{ config, pkgs, lib, ... }:
{
  services.gnome.gnome-browser-connector.enable = true;

  services.xserver.desktopManager.gnome.sessionPath = [ pkgs.gnome-browser-connector ];
  # systemd.packages = [ pkgs.chrome-gnome-shell ];
}

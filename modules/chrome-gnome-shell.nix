{ config, pkgs, lib, ... }:
{
  services.gnome.gnome-browser-connector.enable = true;

  services.xserver.desktopManager.gnome.sessionPath = [ pkgs.chrome-gnome-shell ];
  # systemd.packages = [ pkgs.chrome-gnome-shell ];
}

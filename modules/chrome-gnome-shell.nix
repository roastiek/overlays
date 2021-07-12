{ config, pkgs, lib, ... }:
{
  services.gnome.chrome-gnome-shell.enable = true;

  services.xserver.desktopManager.gnome.sessionPath = [ pkgs.chrome-gnome-shell ];
  # systemd.packages = [ pkgs.chrome-gnome-shell ];
}

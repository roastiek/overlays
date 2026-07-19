{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    # gnome50Extensions."impatience@gfxmonk.net"
    appindicator
    # no-overview
    gnome50Extensions."upower-battery@codilia.com"
    unblank
    no-titlebar-when-maximized
    vertical-workspaces
    # resource-monitor
    astra-monitor
    gnome-shell-extensions
  ];

  services.desktopManager.gnome.sessionPath = with pkgs; [ libgtop ];
}

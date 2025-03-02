{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    gnome47Extensions."impatience@gfxmonk.net"
    appindicator
    no-overview
    gnome47Extensions."upower-battery@codilia.com"
    unblank
    no-titlebar-when-maximized
    vertical-workspaces
    resource-monitor
  ];
}

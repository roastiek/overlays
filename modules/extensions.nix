{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    #impatience
    gnome44Extensions."impatience@gfxmonk.net"
    #gnome44Extensions."noannoyance-fork@vrba.dev"
    appindicator
    no-overview
    upower-battery
    unblank
    ( no-title-bar.overrideAttrs ( oldAttrs: { patches = ( oldAttrs.patches or [] ) ++ [
        ../mypkgs/no-title-bar.patch
      ]; } ) )
    (resource-monitor.overrideAttrs ( oldAttrs: { patches = ( oldAttrs.patches or [] ) ++ [
        ../mypkgs/resource-monitor/disk.patch
        ../mypkgs/resource-monitor/units.patch
        ../mypkgs/resource-monitor/autohide.patch
        ../mypkgs/resource-monitor/thermal.patch
        ../mypkgs/resource-monitor/freqs.patch
      ]; }))
  ];
}

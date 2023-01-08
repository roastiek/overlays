{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    bluetooth-quick-connect 
    caffeine
    disconnect-wifi
    #impatience
    gnome43Extensions."impatience@gfxmonk.net"
    #noannoyance
    gnome43Extensions."noannoyance@daase.net"
    gnome43Extensions."appindicatorsupport@rgcjonas.gmail.com"
    no-overview
    vertical-overview
    #vitals
    #volume-mixer
    no-title-bar
    (resource-monitor.overrideAttrs ( oldAttrs: { patches = [
        ../mypkgs/resource-monitor/disk.patch
        ../mypkgs/resource-monitor/units.patch
        ../mypkgs/resource-monitor/autohide.patch
      ]; }))
  ];
}

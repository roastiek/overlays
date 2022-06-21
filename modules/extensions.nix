{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    bluetooth-quick-connect 
    caffeine
    disconnect-wifi
    #impatience
    gnome42Extensions."impatience@gfxmonk.net"
    #noannoyance
    gnome42Extensions."noannoyance@daase.net"
    gnome42Extensions."appindicatorsupport@rgcjonas.gmail.com"
    no-overview
    vertical-overview
    #vitals
    #volume-mixer
    no-title-bar
    (resource-monitor.overrideAttrs ( oldAttrs: { patches = [ ../mypkgs/resource-monitor/disk.patch ]; }))
  ];
}
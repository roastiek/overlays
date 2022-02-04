{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    bluetooth-quick-connect 
    caffeine
    disconnect-wifi
    #impatience
    gnome41Extensions."impatience@gfxmonk.net"
    #noannoyance
    gnome41Extensions."noannoyance@daase.net"
    gnome41Extensions."appindicatorsupport@rgcjonas.gmail.com"
    no-overview
    vertical-overview
    vitals
    #volume-mixer
    no-title-bar
  ];
}
{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    bluetooth-quick-connect 
    caffeine
    disconnect-wifi
    #impatience
    gnome40Extensions."impatience@gfxmonk.net"
    #noannoyance
    gnome40Extensions."noannoyance@daase.net"
    no-overview
    vertical-overview
    vitals
    volume-mixer
  ];
}
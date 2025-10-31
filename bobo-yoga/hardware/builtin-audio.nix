{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ 
    ( import ./alsa ) 
  ];

  services.pipewire.package = pkgs.alsa1_2_14.pipewire;
  services.pipewire.wireplumber.package = pkgs.alsa1_2_14.wireplumber;
}
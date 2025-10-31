{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ 
    ( import ./intel )
  ];
}
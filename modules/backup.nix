{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kopia kopia-ui
  ];
}
{ config, lib, pkgs, ... }:
{
  users.users.bobo = {
    isNormalUser = true;
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" "docker" "lxd" "power" ]; # Enable ‘sudo’ for the user.
  };
}
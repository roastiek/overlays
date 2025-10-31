{ config, lib, pkgs, ... }:
{
  services.printing.enable = true;
  environment.etc."samba/smb.conf".text = "";
}
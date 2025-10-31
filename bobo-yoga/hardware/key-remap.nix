{ config, lib, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    keyd
  ];

  services.keyd = {
    enable = true;
    keyboards = {
      laptop = {
        ids = [ "0001:0001:09b4e68d" ];
        settings = {
          main = {
            "leftshift+leftmeta+f23" = "layer(control)";
          };
        }; 
      };
    };
  };

  systemd.services.keyd.serviceConfig.Group = "keyd";
  systemd.services.keyd.serviceConfig.SuccessExitStatus= "15";

  users.groups.keyd = {};
}
{ config, lib, pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
  };

  boot.initrd.systemd.enable = true;

  boot.consoleLogLevel = 3;
  boot.loader.timeout = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];
}
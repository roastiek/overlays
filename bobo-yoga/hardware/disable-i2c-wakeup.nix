{ config, lib, pkgs, ... }:
{
  systemd.services.disable-i2c-wakeup = {
    wantedBy = [ "multi-user.target" ];
    after = [ "basic.target" ];
    script = ''
      echo "disabled" > /sys/bus/i2c/devices/i2c-CIRQ1080:00/power/wakeup
    '';
    serviceConfig = {
      Type = "oneshot";  
      RemainAfterExit = true;    
    };
  };
}
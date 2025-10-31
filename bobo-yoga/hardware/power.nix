{ config, lib, pkgs, ... }:
{
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      #PLATFORM_PROFILE_ON_AC = "balanced"; #performance 
      #PLATFORM_PROFILE_ON_BAT = "low-power";
      
      DISK_DEVICES = "nvme0n1";

      USB_AUTOSUSPEND = 1;

      DISK_APM_LEVEL_ON_BAT = "254";

      DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi";
      DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";

      RESTORE_DEVICE_STATE_ON_STARTUP = 0;
      DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth";

      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 1;

      TLP_DEBUG="arg bat disk lock nm path pm ps rf run sysfs udev usb";
    };
  };

  environment.systemPackages = with pkgs; [
    i7z
    powertop
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.turbostat
    intel-undervolt
    # thermald
    # thermal-monitor
  ];

  systemd.services.tlp = {
    before = [ "bluetooth.service" ];
    after = [ "NetworkManager.service" ];
  };
}
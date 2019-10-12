{ lib, pkgs, config, ...}:

let
  script = ./attwifi.py;
  config = ./hostapd-attwifi.conf;
in

{
  networking.networkmanager.unmanaged = [ "mac:00:0e:2e:f1:3c:cf" "interface-name:attwifi" ];
  networking.usePredictableInterfaceNames = false;

  systemd.network.enable = true;
  systemd.network.links."70-edimax1.3" = {
    enable = true;
    matchConfig = {
      MACAddress = "00:0e:2e:f1:3c:cf";
      Path = "pci-0000:00:1d.7-usb-0:1.3:1.0";
    };
    linkConfig = {
      OriginalName = "attwifi";
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="148f", ATTRS{idProduct}=="2573", TAG+="systemd", ENV{SYSTEMD_WANTS}="hostapd-attwifi.service"  
  '';
  systemd.services.hostapd-attwifi = {
    bindsTo = [ "sys-subsystem-net-devices-attwifi.device" ];
    after = [ "sys-subsystem-net-devices-attwifi.device" ];
    path = [ pkgs.python pkgs.wirelesstools pkgs.iproute pkgs.hostapd ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${script} ${config}";
    };
  };
}

{ config, lib, pkgs, ... }:
{
  services.usbguard.enable = true;
  services.usbguard.dbus.enable = true;
  # #services.usbguard.implictPolicyTarget = "allow";
  # #services.usbguard.presentDevicePolicy = "keep";
  services.usbguard.IPCAllowedGroups = [ "wheel" ];
  # systemd.services.usbguard-dbus = {
  #   requires = [ "usbguard.service" ];
  #   description =  "USBGuard D-Bus Service";
  #   documentation = [ "man:usbguard-dbus(8)" ];
  #   serviceConfig = {
  #     Type = "dbus";
  #     BusName = "org.usbguard1";
  #     ExecStart="${config.services.usbguard.package}/bin/usbguard-dbus --system";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  #   aliases = [ "dbus-org.usbguard.service" ];
  # };

  # systemd.services.usbguard = {
  #   serviceConfig = {
  #     DevicePolicy = lib.mkForce "closed";
  #     ReadWritePaths = lib.mkForce "-/dev/shm -/tmp -/var/lib/usbguard -/etc/usbgurad";
  #   };
  # };
}
{ config, lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;

  networking.useDHCP = false;

  networking.firewall = {
    enable = true;
  };
  networking.firewall.allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];
  networking.networkmanager.dns = "dnsmasq";
  networking.networkmanager.settings.main.systemd-resolved = false;

  environment.systemPackages = with pkgs; [
    tunctl
    iptables
    ethtool
    tcpdump
    bridge-utils
  ];

}
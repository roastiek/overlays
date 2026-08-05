{ config, lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;

  networking.useDHCP = false;

  networking.firewall = {
    enable = true;
  };
  networking.firewall.allowedTCPPortRanges = [ { from = 1024; to = 65000;} ];

  # DNS queries to dnsmasq (on 169.254.53.53) from docker containers ingress
  # on docker0 (their default gateway), so open port 53 there rather than on
  # the dns0 dummy interface (which never sees ingress traffic).
  networking.firewall.interfaces.docker0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  networking.networkmanager.dns = "dnsmasq";
  networking.networkmanager.settings.main.systemd-resolved = false;

  # Dummy interface that dnsmasq (managed by NetworkManager) uses as an extra
  # listen interface. Created and addressed via systemd-networkd, and left
  # unmanaged by NetworkManager so the two don't fight over it.
  systemd.network.enable = true;

  # Enabling systemd-networkd defaults services.resolved on, which would set
  # networking.networkmanager.dns = "systemd-resolved" and conflict with our
  # dnsmasq choice. We use dnsmasq, so keep resolved off.
  services.resolved.enable = false;

  systemd.network.netdevs."10-dns0" = {
    netdevConfig = {
      Kind = "dummy";
      Name = "dns0";
    };
  };

  systemd.network.networks."10-dns0" = {
    matchConfig.Name = "dns0";
    address = [ "169.254.53.53/32" ];
    networkConfig.LinkLocalAddressing = "ipv6";
  };

  networking.networkmanager.unmanaged = [ "interface-name:dns0" ];

  # Make NetworkManager's dnsmasq also listen on the dummy interface's address.
  # Use listen-address (not interface=dns0): dnsmasq's interface= filters by the
  # packet's *arrival* interface, but queries to 169.254.53.53 from containers
  # ingress on docker0/bridges, so an interface filter silently drops them.
  # listen-address keys off the destination address and answers regardless of
  # which interface the query arrived on. bind-dynamic lets it bind the address
  # whenever dns0 comes up.
  environment.etc."NetworkManager/dnsmasq.d/dns0.conf".text = ''
    listen-address=169.254.53.53
    bind-dynamic
  '';

  environment.systemPackages = with pkgs; [
    tunctl
    iptables
    ethtool
    tcpdump
    bridge-utils
  ];

}
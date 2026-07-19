{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    socketActivation = true;
  };

  users.groups.incus-admin.members = [ "bobo" ];

  networking.nftables.enable = true;

  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  networking.networkmanager.unmanaged = [
    "incusbr0"
    "docker0"
  ];

  environment.etc."NetworkManager/dnsmasq.d/00-incus.conf" = {
    text = ''
      server=/incus/10.2.39.1
    '';
  };
}

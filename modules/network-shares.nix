{ config, lib, pkgs, ... }:
{
  fileSystems."/remote/amour" =
    { device = "ruster:/Amour";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };

  fileSystems."/remote/music" =
    { device = "ruster:/Music";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };

  fileSystems."/remote/download" =
    { device = "ruster:/Download";
      fsType = "nfs";
      options = [ "user" "soft" "noauto" "nofail" "_netdev" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=30min" "nfsvers=4.0" ];
    };

  environment.systemPackages = with pkgs; [
    cifs-utils
    nfs-utils
  ];

}
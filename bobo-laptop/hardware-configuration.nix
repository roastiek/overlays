# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
    "hid_microsoft" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "systemd.restore_state=0" "button.lid_init_state=method" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d4c04bfe-2e89-46f8-b9e2-b87397ee4ccb";
      fsType = "btrfs";
      options = [ "subvol=nixos" "noatime" "autodefrag" ];
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/0e81c49c-157b-40ae-8b2a-78057063a554";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/91289f45-d8aa-4559-9f4a-522a9996f564";
      fsType = "btrfs";
      options = [ "subvol=nixos-boot" "noatime" "autodefrag" ];
    };

  fileSystems."/tmp" =
    { device = "none";
      fsType = "tmpfs";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/0E7A-43E5";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  nix.buildCores = lib.mkDefault 4;
}

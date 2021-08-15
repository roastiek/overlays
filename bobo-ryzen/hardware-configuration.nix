# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    { device = "/dev/mapper/nixos-system";
      fsType = "btrfs";
      options = [ "subvol=nixos" "noatime" "autodefrag" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/nixos-system";
      fsType = "btrfs";
      options = [ "subvol=home" "noatime" "autodefrag" ];
    };

  fileSystems."/home_setup" =
    { device = "/dev/mapper/nixos-system";
      fsType = "btrfs";
      options = [ "subvol=home_setup" "noatime" "autodefrag" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DE63-44A2";
      fsType = "vfat";
    };

  fileSystems."/tmp" =
    { device = "none";
      fsType = "tmpfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 100;
  nix.buildCores = lib.mkDefault 16;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}

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
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_4;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "i915"
    "nvme" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    # "memmap=14M$18M"
    #"memmap=12M$20M"
    #"memmap=0x287E000$0x59782000"
    #"memmap=0x1000%0x59782000-1+2"
    # "intel_pstate=no_hwp"
    # "initcall_debug"
    "intel_pstate=active"
    #"intel_pstate=passive"
  ];

  system.fsPackages = [ pkgs.ntfs3g ];

  # boot.extraModprobeConfig = ''
  #   options i915 fastboot=1
  # '';

  # boot.kernelPatches = [ {
  #   name = "enable-qca6390-bluetooth";
  #   patch = null;
  #   extraConfig = ''
  #     BT_QCA m
  #     BT_HCIUART m
  #     BT_HCIUART_QCA y
  #     BT_HCIUART_SERDEV y
  #     SERIAL_DEV_BUS y
  #     SERIAL_DEV_CTRL_TTYPORT y
  #   '';
  # }
  # ];

  boot.blacklistedKernelModules = [ "psmouse" ];

  boot.initrd.luks.devices.cryptlvm =
    { device = "/dev/disk/by-uuid/ce839805-9f43-43a4-b607-7b372a21ee50";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fbc44830-e249-420f-9ade-a728191708c3";
      fsType = "btrfs";
      options = [ "subvol=nixos" "noatime" "autodefrag" ];
    };

  fileSystems."/home-boot" =
    { device = "/dev/disk/by-uuid/fbc44830-e249-420f-9ade-a728191708c3";
      fsType = "btrfs";
      options = [ "subvol=home" "noatime" "autodefrag" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/fbc44830-e249-420f-9ade-a728191708c3";
      fsType = "btrfs";
      options = [ "subvol=nixos/home-ro" "noatime" "autodefrag" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/00D5-71B0";
      fsType = "vfat";
    };

  fileSystems."/tmp" =
    { device = "none";
      fsType = "tmpfs";
    };

  swapDevices = [ ];

  nix = {
    settings = {
      max-jobs = lib.mkDefault 100;
      cores = lib.mkDefault 6;
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # high-resolution display
  hardware.graphics.enable32Bit = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.sensor.iio.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    #CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    SCHED_POWERSAVE_ON_AC = 1;
    SCHED_POWERSAVE_ON_BAT = 1;

    DISK_DEVICES = "nvme0n1";

    USB_AUTOSUSPEND = 0;
    # USB_BLACKLIST = "0bda:8153";

    DISK_APM_LEVEL_ON_BAT = "254";

    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi";
    DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
  };

  services.thermald = {
    enable = true;
    debug = false;
    configFile = ./thermal-conf.xml.default;
  };

}

{ config, lib, pkgs, ... }:
{
  system.fsPackages = [ pkgs.ntfs3g ];

  services.fwupd.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';
  services.journald.rateLimitInterval = "0";

  services.fstrim.enable = true;
  systemd.services.fstrim.after = [ "nix-optimise.service" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.command-not-found.enable = true;
  programs.bash.completion.enable = true;
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    sysfsutils

    htop
    mc
    file
    zip
    unzip
    unrar
    wget
    tree
    curl

    nixfmt-rfc-style
  ];

}
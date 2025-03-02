{ config, pkgs, lib, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # systools
    tcpdump
    bridge-utils
    aspellDicts.cs
    aspellDicts.en
    cifs-utils
    nfs-utils
    usbutils
    pciutils
    sysfsutils
    alsa-utils
    pavucontrol
    snappers

    # work tools
    git
    mc
    file
    dpkg
    htop
    zip
    unzip
    unrar
    wget
    tree
    gnumake
    kubectl
    jq
    yq-go
    direnv

    # gui apps
    vivaldi
    zoom-us
    ( vscodium-fhsWithPackages { additionalPkgs = pkgs: [
      pkgs.go pkgs.gopls pkgs.gotools pkgs.go-tools pkgs.delve pkgs.gotests
      pkgs.jdk17 ]; profile = ''
      JAVA_HOME=/usr/lib64/openjdk
    '';} )
    libreoffice

    # gui tools
    zenity
    gnome-tweaks
    tango-icon-theme
    tango-extras-icon-theme
    keepassxc
    dconf-editor
    gnome-terminal

    # media
    gimp
    viewnior
    picard
    plex-media-player
    clementine
    strawberry
    vlc
    mpv
    kid3
    easytag

  ];
}

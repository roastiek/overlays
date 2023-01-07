{ config, pkgs, lib, ... }:
{
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
    firefox
    vivaldi
    zoom-us
    ( vscodium-fhsWithPackages { additionalPkgs = pkgs: [ pkgs.go_1_19 pkgs.jdk17 ]; profile = ''
      JAVA_HOME=/usr/lib64/openjdk
    '';} )
    libreoffice

    # gui tools
    gnome.zenity
    gnome.gnome-tweaks
    tango-icon-theme
    tango-extras-icon-theme
    keepassxc
    gnome.dconf-editor
    gnome.gnome-terminal

    # media
    gimp
    viewnior
    picard
    plex-media-player
    clementine
    vlc
    mpv
    kid3
    easytag

  ];
}

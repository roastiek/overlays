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
    direnv

    # gui apps
    firefox
    vivaldi
    minetime
    zoom-us
    vscodium
    libreoffice

    # gui tools
    gnome.zenity
    gnome.gnome-tweak-tool
    tango-icon-theme
    tango-extras-icon-theme
    keepassx-community
    gnome.dconf-editor

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

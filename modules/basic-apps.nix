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
    direnv

    # gui apps
    firefox
    vivaldi
    zoom-us
    vscodium
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

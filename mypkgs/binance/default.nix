{ stdenv, fetchurl, dpkg, autoPatchelfHook
, zlib, libusb1, libglvnd, nss, expat, freetype, fontconfig
, libXcomposite, libXcursor, libXdamage, libXi, libXtst
, alsa-lib, dbus, glib, libxcb, wayland, libxkbcommon, libdrm
, libX11, cairo, libXrandr, gtk3, popt, libxshmfence, mesa, libva
, systemd }:
stdenv.mkDerivation rec {
  version = "1.30.1";
  pname = "binance";

  src = fetchurl {
    url = "https://ftp.binance.com/electron-desktop/linux/production/binance-amd64-linux.deb";
    sha256 = "0x8vx2f13z3jfb6i897zig92n1mf4v1yzys0xyxi4j26zrajkvsa";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  buildInputs = [
    #stdenv.cc.cc.lib
    #zlib libusb1 libglvnd expat freetype fontconfig
    #libXcomposite libXcursor  libXi libXtst
    #glib wayland
    nss
    dbus
    libxcb
    libxkbcommon
    libX11
    alsa-lib
    cairo
    libdrm
    libXrandr
    gtk3
    popt
    libxshmfence
    libXdamage
    mesa

    # qtbase qtwayland
  ];

  runtimeDependencies = [
    systemd
  ];


  phases = [ "unpackPhase" "installPhase" "fixupPhase" "distPhase" ];

  unpackPhase = ''
    dpkg-deb -R $src .
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    ls -l
    #exit 1

    cp -dr usr/share $out/
    mkdir -p $out/lib
    cp -dr opt/* $out/lib

    mkdir -p $out/bin
    ln -s $out/lib/Binance/binance $out/bin
    substituteInPlace $out/share/applications/binance.desktop --replace /opt/Binance/binance binance

    runHook postInstall
  '';

}

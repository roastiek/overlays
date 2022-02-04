{ stdenv, fetchurl, dpkg, autoPatchelfHook
, zlib, libusb1, libglvnd, nss, expat, freetype, fontconfig
, libXcomposite, libXcursor, libXdamage, libXi, libXtst
, alsa-lib, dbus, glib, libxcb, wayland, libxkbcommon, libdrm
, libX11, qtbase, qtwayland }:
stdenv.mkDerivation rec {
  version = "1.0.5.0305";
  pname = "qsync";

  src = fetchurl {
    url = "https://download.qnap.com/Storage/Utility/QNAPQsyncClientUbuntux64-${version}.deb";
    sha256 = "1z93ainkc67chrklzy92b473hy1l6xsx2nj457v12bhwjk0606jj";
  };

  #autoPatchelfIgnoreMissingDeps = true;

  outputs = [ "out" "plugin" ];

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib libusb1 libglvnd nss expat freetype fontconfig
    libXcomposite libXcursor libXdamage libXi libXtst
    alsa-lib dbus glib libxcb wayland libxkbcommon libdrm
    libX11 qtbase qtwayland
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" "distPhase" ];

  unpackPhase = ''
    dpkg-deb -R $src .
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir -p $plugin

    cp -dr usr/share $out/
    cp -dr usr/local/* $out/
    #cp -dr usr/lib $plugin/
    mkdir -p $plugin/share
    #mv $out/share/ $plugin/share/nautilus-qsync
    mv $out/bin/QNAP/QsyncClient/* $out/bin
    mv $out/lib/QNAP/QsyncClient/* $out/lib
    #rm -rf $out/lib/QNAP/QsyncClient/
    #cp -dr usr/local/lib/QNAP/QsyncClient/{libQUiLib*,libP2PTunnelAPIs*,libIOTCAPIs*,libRDTAPIs*} $out/lib/

    runHook postInstall
  '';

}

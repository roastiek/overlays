{ stdenv, thermald, wrapQtAppsHook, qmake, fetchFromGitHub, xz, pkg-config }:
stdenv.mkDerivation rec {
  pname = "thermal-monitor";
  version = "2.4.8";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "thermal_daemon";
    rev = "v${version}";
    sha256 = "sha256-Mup88vNS0iApwsZTdPnpXmkA0LNpSOzxBmbejcWIC+0=";
  };

  preConfigure = ''
    cd tools/thermal_monitor
    pwd
  '';

  nativeBuildInputs = [ qmake wrapQtAppsHook pkg-config xz.dev ];

  buildInputs = [ xz.dev ];

  preInstall = ''
    mkdir -p $out/bin
    cp ThermalMonitor $out/bin
  '';

}

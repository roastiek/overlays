{ stdenv, thermald, wrapQtAppsHook, qmake }:
stdenv.mkDerivation {
  name = "thermal-monitor";
  src = thermald.src;

  preConfigure = ''
    cd tools/thermal_monitor
    pwd
    ls -l
  '';

  nativeBuildInputs = [ qmake wrapQtAppsHook ];

  preInstall = ''
    mkdir -p $out/bin
    cp ThermalMonitor $out/bin
  '';
}

{ stdenv, lib, fetchzip, python3, makeWrapper, libpulseaudio }:
let
  libPath = lib.makeLibraryPath [ libpulseaudio ];
in stdenv.mkDerivation rec {
  name = "gnome-shell-volume-mixer-${version}";
  version = "40";

  src = fetchzip {
    url = "https://github.com/aleho/gnome-shell-volume-mixer/releases/download/40.0/shell-volume-mixer-40.0.zip";
    sha256 = "0r45azk2jcg8j3kjp6vk954bawhy67sc9c8xq7r72cyh0a5hwqrd";
    stripRoot = false;
  };

  buildInputs = [
    makeWrapper
  ];

  nativeBuildInputs = [
    python3
  ];

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r * $out/share/gnome-shell/extensions/${uuid}
    patchShebangs $out/share/gnome-shell/extensions/${uuid}/pautils/*py
    wrapProgram $out/share/gnome-shell/extensions/${uuid}/pautils/query.py \
      --prefix LD_LIBRARY_PATH : ${libPath}
    substituteInPlace $out/share/gnome-shell/extensions/${uuid}/lib/utils/paHelper.js \
      --replace 'let PYTHON;' 'let PYTHON="python3";' \
      --replace "'/usr/bin/env', python, paUtilPath" paUtilPath
  '';

  uuid = "shell-volume-mixer@derhofbauer.at";

  meta = with lib; {
    description = "GNOME Shell Extension allowing separate configuration of PulseAudio devices";
    license = licenses.gpl2;
    maintainers = with maintainers; [ aneeshusa ];
    homepage = https://github.com/aleho/gnome-shell-volume-mixer;
  };
}

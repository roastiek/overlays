{ stdenv, lib, fetchFromGitHub, glib, python, makeWrapper, libpulseaudio }:
let
  libPath = lib.makeLibraryPath [ libpulseaudio ];
in stdenv.mkDerivation rec {
  name = "gnome-shell-volume-mixer-${version}";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "aleho";
    repo = "gnome-shell-volume-mixer";
    rev = "v${version}";
    sha256 = "1gzi9v191pavi2b2wswx0jky4631abm2c3gxzm82hsw3hyl55814";
  };

  patches = [ ./fix-python-path.patch ];

  buildInputs = [
    glib python makeWrapper
  ];

  buildPhase = ''
    ${glib.dev}/bin/glib-compile-schemas --targetdir=${uuid}/schemas ${uuid}/schemas
  '';

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r ${uuid} $out/share/gnome-shell/extensions/
    wrapProgram $out/share/gnome-shell/extensions/${uuid}/pautils/cardinfo.py \
      --prefix LD_LIBRARY_PATH : ${libPath}
  '';

  uuid = "shell-volume-mixer@derhofbauer.at";

  meta = with stdenv.lib; {
    description = "GNOME Shell Extension allowing separate configuration of PulseAudio devices";
    license = licenses.gpl2;
    maintainers = with maintainers; [ aneeshusa ];
    homepage = https://github.com/aleho/gnome-shell-volume-mixer;
  };
}

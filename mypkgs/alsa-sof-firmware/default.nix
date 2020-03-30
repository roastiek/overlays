{stdenv, fetchurl, cmake, alsaLib, m4, alsaUtils, fetchFromGitHub }:

let
  extra = fetchurl {
    url = "https://github.com/thesofproject/sof/releases/download/v1.4.2/sof-cnl-v1.4.2.ri";
    sha256 = "02xgm50gzxfsbh539gxhdfkr3dak8dx9c77k1bl969a3ihdxni8s";
  };
in

stdenv.mkDerivation rec {
  name = "alsa-sof-firmware-1.4.2";

  # src = fetchurl {
  #   url = "https://github.com/thesofproject/sof/archive/v1.4.2.tar.gz";
  #   sha256 = "1hhncqm0hrbpaiwvh0mfdmgys4wyn1zcp28lrac7wi2a2cp7q29w";
  # };

  src = fetchFromGitHub {
    owner = "thesofproject";
    repo = "sof";
    rev = "392b784910837c8ec7822909b4621284ebce71da";
    sha256 = "0ap25yy46n7k2lk8dswyqxlp51pd8balf6zj4gpfhl3n0mj8nvhw";
  };

  nativeBuildInputs = [ cmake m4 alsaUtils ];

  buildInputs = [ alsaLib ];

  preConfigure = ''
    cd tools
    patchShebangs .
    substituteInPlace logger/CMakeLists.txt --replace '-Werror' ""
  '';

  postInstall = ''
    mkdir -p $out/lib/firmware/intel/sof-tplg
    cp -r topology/* $out/lib/firmware/intel/sof-tplg
    mkdir -p $out/lib/firmware/intel/sof/
    cp ${extra} $out/lib/firmware/intel/sof/sof-cnl-v1.4.2.ri
    ln -s $out/lib/firmware/intel/sof/sof-cnl-v1.4.2.ri $out/lib/firmware/intel/sof/sof-cml.ri
  '';

  dontStrip = true;
  dontFixup = true;

  meta = {
    homepage = http://www.alsa-project.org/;
    description = "Soundcard firmwares from the alsa project";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.linux;
  };
}

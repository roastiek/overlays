{ stdenv
, gtk3 /*any version*/
}:

stdenv.mkDerivation rec {
  name = "tango-extras-icon-theme-0";

  src = ./tango-extras.tar.gz;

  dontBuild = true;

  installPhase = ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve='ownership' . $out/share/icons/TangoExtras/
    ${gtk3.out}/bin/gtk-update-icon-cache $out/share/icons/TangoExtras
  '';

  meta = {
    description = "A basic set of icons";
    homepage = http://tango.freedesktop.org/Tango_Icon_Library;
    platforms = stdenv.lib.platforms.linux;
  };
}

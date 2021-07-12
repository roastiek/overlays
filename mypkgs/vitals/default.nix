{ lib, stdenv, libgtop, gnome40Extensions }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-vitals";
  version = "unstable-2021-07-12";

  # src = fetchFromGitHub {
  #   owner = "corecoding";
  #   repo = "Vitals";
  #   rev = "85558717e1539d1618fde3905c2b0d73f998f8cc";
  #   sha256 = "0n9z851snqaafxykxfvm3vngcgkaq7rszw8wwm0j1hpnikkbvkmx";
  # };

  src = gnome40Extensions."Vitals@CoreCoding.com".src;

  patches = [
    ./to42.patch
    ./custom.patch
  ];

  buildPhase = ''
    runHook preBuild
    sed -i "1iimports\.gi\.GIRepository\.Repository\.prepend_search_path('${libgtop}/lib/girepository-1.0');\n" extension.js
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r * $out/share/gnome-shell/extensions/${uuid}
    #mkdir -p $out/
    #cp -r * $out/
    runHook postInstall
  '';

  uuid = "Vitals@CoreCoding.com";
}

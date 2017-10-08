{ stdenv, fetchurl, cmake, qt5, libgpgerror, libgcrypt, libmicrohttpd, libyubikey, yubikey-personalization, libXtst, libXi }:

stdenv.mkDerivation rec {
  name = "keepassxc-${version}";
  version = "2.2.0";

  src = fetchurl {
    url = "https://github.com/keepassxreboot/keepassxc/releases/download/${version}/keepassxc-${version}-src.tar.xz";
    sha256 = "71c47ebd9a661fc439c61566e4a4aa482e4d463c0eaa4f7562e7216eb0327e59";
  };

  buildInputs = [ cmake qt5.qtbase qt5.qttools qt5.qtx11extras libgpgerror libgcrypt libmicrohttpd libyubikey yubikey-personalization libXtst libXi ];

  cmakeFlags = "-DWITH_XC_AUTOTYPE=ON -DWITH_XC_HTTP=ON -DWITH_XC_YUBIKEY=ON";

  enableParallelBuilding = true;
}

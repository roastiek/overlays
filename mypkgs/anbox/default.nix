{ stdenv, fetchFromGitHub, cmake, pkgconfig, boost, mesa_glu, libX11, protobuf, SDL2, SDL2_image, libdbus-cpp, lxc, glib, properties-cpp, python, glm }:
stdenv.mkDerivation {
  name = "anbox";
  
  src = fetchFromGitHub {
    owner = "anbox";
    repo = "anbox";
    rev = "df774db4a8e1f0b59b4de6e61a71e3c209b66d53";
    sha256 = "1p19c88yc7d2ffr29x79gnn0394wg9g33k8300mdzr705qqgl31y";
  };

  preConfigure = ''
    sed -e 's/add_subdirectory(tests)//' -e 's/find_package(GMock)//' -i CMakeLists.txt
    sed 's/.*unittest.*//' -i external/android-emugl/shared/emugl/common/CMakeLists.txt
  '';

  buildInputs = [ cmake pkgconfig boost mesa_glu libX11 protobuf SDL2 SDL2_image libdbus-cpp lxc glib properties-cpp python glm ];

  enableParallelBuilding = true;
}

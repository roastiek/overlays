{ stdenv, fetchbzr, cmake, pkgconfig, boost, libxml2, dbus, process-cpp }:
stdenv.mkDerivation {
  name = "libdbus-cpp";
  
  src = fetchbzr {
    url = "http://bazaar.launchpad.net/~phablet-team/dbus-cpp/trunk";
    rev = "103";
    sha256 = "0mrqh6ynj41fscrhzgagd8m9s45flvrqdacbhk8bi1337vy68m9w";
  };

  preConfigure = ''
    sed 's/add_subdirectory(tests)//' -i CMakeLists.txt 
  '';

  cmakeFlags = [ "-DDBUS_CPP_VERSION_MAJOR=5" "-DDBUS_CPP_VERSION_MINOR=0" "-DDBUS_CPP_VERSION_PATCH=0"];

  buildInputs = [ cmake pkgconfig boost libxml2 process-cpp ];
  
  propagatedBuildInputs = [ dbus ];

  enableParallelBuilding = true;
}

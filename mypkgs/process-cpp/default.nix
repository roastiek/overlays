{ stdenv, fetchbzr, cmake, pkgconfig, boost, libxml2, dbus, properties-cpp }:
stdenv.mkDerivation {
  name = "process-cpp";
  
  src = fetchbzr {
    url = "http://bazaar.launchpad.net/~phablet-team/process-cpp/trunk";
    rev = "54";
    sha256 = "10529r9nhry80w4m2424il561xbirz7b5fx0s0sw02qcjp362afp";
  };

  preConfigure = ''
    sed 's/add_subdirectory(tests)//' -i CMakeLists.txt 
  '';

  buildInputs = [ cmake pkgconfig boost ];
  
  propagatedBuildInputs = [ properties-cpp  ];

  enableParallelBuilding = true;
}

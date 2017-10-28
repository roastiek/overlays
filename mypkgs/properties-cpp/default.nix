{ stdenv, fetchbzr, cmake, boost }:
stdenv.mkDerivation {
  name = "properties-cpp";
  
  src = fetchbzr {
    url = "http://bazaar.launchpad.net/~phablet-team/properties-cpp/trunk";
    rev = "17";
    sha256 = "03lf092r71pnvqypv5rg27qczvfbbblrrc3nz6m9mp7j4yfp012w";
  };

  preConfigure = ''
    sed 's/add_subdirectory(tests)//' -i CMakeLists.txt 
  '';

  buildInputs = [ cmake  boost ];

  enableParallelBuilding = true;
}

{ pythonPackages, fetchurl, zlib, boringssl, c-ares, protobuf }:

with pythonPackages; buildPythonPackage rec {
  name = "grpc-${version}";
  version = "1.6.0";

  src = fetchurl {
    url = "https://pypi.python.org/packages/bd/4f/c6bc9d402ac9042853ec36d732d9de0a0a399ceb64a317f7eaacc10957eb/grpcio-1.6.0.tar.gz";
    sha256 = "0l0yir0lf7iwgql0vgh6mmirfi7i8wvabwk8i5x5hlzc2par7mvc";
  };

  # patches = [ ./custom.patch ];

  propagatedBuildInputs = [ protobuf ];

  buildInputs = [ zlib c-ares six ];

  #GRPC_PYTHON_BUILD_WITH_CYTHON = "True";

  dontStrip = true;
}

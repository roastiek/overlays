{ pythonPackages, fetchurl, zlib, boringssl, c-ares, protobuf }:

with pythonPackages; buildPythonPackage rec {
  name = "grpc-${version}";
  version = "1.4.0";

  src = fetchurl {
    url = "https://pypi.python.org/packages/1b/40/3e89d778c9a5a5a59bc6ef80c8f096ea8b9e02a30e163479d1501257b8a6/grpcio-${version}.tar.gz";
    sha256 = "0d7grnkg6fgscrhpph03bpxbiwd3fhxjwxbd70mmfp2bqaj178m3";
  };

  patches = [ ./custom.patch ];

  propagatedBuildInputs = [ protobuf ];

  buildInputs = [ cython zlib c-ares six ];

  GRPC_PYTHON_BUILD_WITH_CYTHON = "True";

  dontStrip = true;
}

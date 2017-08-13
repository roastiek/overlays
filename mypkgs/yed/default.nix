{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  name = "yEd-${version}";
  version = "3.17";

  src = fetchurl {
    url = "http://www.yworks.com/resources/yed/demo/yEd-${version}.zip";
    sha256 = "1wk58cql90y3i5l7jlxqfjjgf26i0zrv5cn0p9npgagaw6aiw2za";
  };

  buildInputs = [ unzip ];

  buildCommand = ''
    unzip $src -d $out
    mkdir -p $out/bin
    cat >$out/bin/yed <<EOF
    #!/bin/sh
    exec java -jar $out/yed-${version}/yed.jar
    EOF
    chmod +x $out/bin/yed
  '';
}

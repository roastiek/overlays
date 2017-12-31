{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "goenvtemplator-${version}";
  version = "v2.0.0-rc3";
  goPackagePath = "github.com/seznam/goenvtemplator";

  src = fetchFromGitHub {
    owner = "seznam";
    repo = "goenvtemplator";
    rev = version;
    sha256 = "179ki9vdxav88lwv26k2qdja3sq0gnmklrd8i88vxn18g6jxgjrv";
  };

  goDeps = ./deps.nix;

  postInstall = ''
    mv $bin/bin/goenvtemplator $bin/bin/goenvtemplator2
  '';
}

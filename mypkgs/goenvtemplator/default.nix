{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "goenvtemplator-${version}";
  version = "v2.0.0";
  goPackagePath = "github.com/seznam/goenvtemplator";

  src = fetchFromGitHub {
    owner = "seznam";
    repo = "goenvtemplator";
    rev = version;
    sha256 = "1m8ly6gcabkncdj3q4vzkqrnx7dcbgh3wk80wx41mwy7b2rv4fq0";
  };

  goDeps = ./deps.nix;

  postInstall = ''
    mv $bin/bin/goenvtemplator $bin/bin/goenvtemplator2
  '';
}

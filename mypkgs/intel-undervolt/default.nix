{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "intel-undervolt";

  src = fetchFromGitHub {
    owner = "kitsunyan";
    repo = "intel-undervolt";
    rev = "1.7";
    sha256 = "1fjhjqxhcgzawqmknxhmrkq0b7hjfpw6fcigzyw6vg5yf2lws507";
  };

  installFlags = ''DESTDIR=$(out) BINDIR=/bin'';

}

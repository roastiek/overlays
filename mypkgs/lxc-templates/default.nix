{stdenv, fetchFromGitHub, autoreconfHook, lxc }:
stdenv.mkDerivation rec {
  name = "lxc-templates-${version}";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "lxc-templates";
    rev = name;
    sha256 = "1q64dbnm5bq2rixzfaraa6miwy3l7mg90k02g41743yl45bsbymj";
  };

  buildInputs = [ autoreconfHook ];

  postInstall = ''
    for i in $out/share/lxc/config/*; do
      substituteInPlace $i --replace $out ${lxc}
    done
  '';
}

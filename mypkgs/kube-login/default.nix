{ buildGoModule, pkger }:
buildGoModule rec {
  pname = "kube-login";
  version = "1.2.20";

  subPackages = [ "." ];

  src = builtins.fetchGit {
    url = "git@gitlab.seznam.net:ultra/SCIF/k8s/kube-login.git";
    ref = version;
    allRefs = true;
    rev = "2de7fb3b0e88c761f875ddc2908c32c7f7ef0123";
  };

  overrideModAttrs = oldAttrs: oldAttrs // {
    preConfigure = ''
        cp ${./pkged.go} ./pkged.go
    '';
  };

  vendorHash = "sha256:pVraK3CPrgHi2iXoCETYbEqzAxq7nUf440MdjdsXmXg=";

  nativeBuildInputs = [ pkger ];

  preConfigure = ''
    cp ${./pkged.go} ./pkged.go
  '';
}

{ buildGoModule, pkger }:
buildGoModule rec {
  pname = "kube-login";
  version = "1.2.14";

  subPackages = [ "." ];

  src = builtins.fetchGit {
    url = "git@gitlab.seznam.net:ultra/SCIF/k8s/kube-login.git";
    ref = version;
  };

  overrideModAttrs = oldAttrs: oldAttrs // {
    preConfigure = ''
  #     HOME=/build/pkger pkger
        cp ${./pkged.go} ./pkged.go
    '';

  #   postInstall = ''
  #     cp pkged.go $out/
  #   '';
  };

  vendorSha256 = "sha256:0208zzs0ah8x85nxz2ca2c2077j72rs5d702ksfr1zjcccd1k87k";

  nativeBuildInputs = [ pkger ];

  preConfigure = ''
    cp ${./pkged.go} ./pkged.go
    #pkger
  '';
}

{ buildGoModule, pkger }:
buildGoModule rec {
  pname = "kube-login";
  version = "1.2.15";

  subPackages = [ "." ];

  src = builtins.fetchGit {
    url = "git@gitlab.seznam.net:ultra/SCIF/k8s/kube-login.git";
    ref = version;
    allRefs =  true;
    rev = "54a6d62d3efcbbd73192a980532f9486db514116";
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

  vendorHash = "sha256:86AZGmNM/pCdngKcVnQWR54DBBOKid9tQR1BBfT/CAg=";

  nativeBuildInputs = [ pkger ];

  preConfigure = ''
    cp ${./pkged.go} ./pkged.go
    #pkger
  '';
}

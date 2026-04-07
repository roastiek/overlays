{ config, lib, pkgs, ... }:
{
  virtualisation.podman.enable = true;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.flags = [ "--volumes" ];
  };
  systemd.services.docker-prune.before = [ "nix-gc.service" ];

  programs.direnv.enable = true;
  programs.git.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  environment.variables.JAVAX_NET_SSL_TRUSTSTORE =
    let
      caBundle = config.environment.etc."ssl/certs/ca-bundle.crt".source;
      p11kit = pkgs.p11-kit.overrideAttrs (oldAttrs: {
        mesonFlags = [
          "--sysconfdir=/etc"
          (lib.mesonEnable "systemd" false)
          (lib.mesonOption "bashcompdir" "${placeholder "bin"}/share/bash-completion/completions")
          (lib.mesonOption "trust_paths" (lib.concatStringsSep ":" [
            "${caBundle}"
          ]))
        ];
      });
    in derivation {
      name = "java-cacerts";
      builder = pkgs.writeShellScript "java-cacerts-builder" ''
        ${p11kit.bin}/bin/trust \
          extract \
          --format=java-cacerts \
          --purpose=server-auth \
          $out
      '';
      system = builtins.currentSystem;
    };

  environment.systemPackages = with pkgs; [
    gnumake
    kubectl
    kube-login
    jq
    yq-go
    # direnv
    maven
    vw

    ( vscodium-fhsWithPackages { additionalPkgs = pkgs: [
      pkgs.go pkgs.gopls pkgs.gotools pkgs.go-tools pkgs.delve pkgs.gotests
      pkgs.jdk17 ]; profile = ''
      JAVA_HOME=/usr/lib64/openjdk
    '';} )

    (wrapHelm kubernetes-helm {
      plugins = with kubernetes-helmPlugins; [
        helm-unittest
      ];
    })

    zoom-us
    vscode

    # nix lsps
    nil
    # nixd
  ];

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "bobo";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
    ];
    ensureDatabases = [
      "demopgx"
      "demogorm"
      "demogormcli"
      "demoent"
      "demopggo"
      "demobun"
      "demoxorm"
      "bobo"
    ];
  };
}

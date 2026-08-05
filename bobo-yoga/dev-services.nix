{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.podman.enable = true;

  # Podman (like Docker) strips loopback nameservers from the host resolv.conf
  # when building a container's resolv.conf, then falls back to public DNS that
  # can't resolve internal split-horizon domains. Point it at the dnsmasq
  # listener on dns0 (169.254.53.53), a non-loopback address that survives.
  virtualisation.containers.containersConf.settings.containers.dns_servers = [ "169.254.53.53" ];

  virtualisation.docker = {
    enable = true;
    # package = pkgs.docker_29;
    extraPackages = [ pkgs.nftables ]; # Docker 29 cleans up nftables rules at startup.
    autoPrune.enable = true;
    autoPrune.flags = [ "--volumes" ];
    # Point containers at the NetworkManager/dnsmasq listener on dns0
    # (169.254.53.53). Docker strips loopback (127.0.0.1) nameservers inherited
    # from the host resolv.conf and would otherwise fall back to public 8.8.8.8,
    # which cannot resolve internal split-horizon domains. dns0 is a non-loopback
    # address so it survives into the container's resolv.conf.
    daemon.settings.dns = [ "169.254.53.53" ];
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
          (lib.mesonOption "trust_paths" (
            lib.concatStringsSep ":" [
              "${caBundle}"
            ]
          ))
        ];
      });
    in
    derivation {
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

    (vscodium-fhsWithPackages {
      additionalPkgs = pkgs: [
        pkgs.go
        pkgs.gopls
        pkgs.gotools
        pkgs.go-tools
        pkgs.delve
        pkgs.gotests
        pkgs.jdk17
      ];
      profile = ''
        JAVA_HOME=/usr/lib64/openjdk
      '';
    })

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

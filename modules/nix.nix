{ config, lib, pkgs, ... }:
{
  nix = {
    settings = {
      trusted-substituters = [ "https://cache.nixos.org/" "http://hydra.dev.dszn.cz/" ];
      trusted-public-keys = [ "hydra0:AlUk3PBEX4hBeQin6SdNyabXksKhvIfg3wWpmNiQMoc=" ];
      trusted-users = [ "@wheel" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      keep-env-derivations = true
      experimental-features = nix-command
      narinfo-cache-negative-ttl = 300
      http-connections = 100
    '';
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d --max-freed $((64 * 1024**3))";
      persistent = true;
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
      persistent = true;
    };
  };

  systemd.services.nix-optimise = {
    serviceConfig.Type = "oneshot";
    after = [ "nix-gc.service" ];
  };

  # systemd.services.nix-daemon = {
  #   environment = {
  #     TMPDIR = "/var/tmp";
  #   };
  # };
}
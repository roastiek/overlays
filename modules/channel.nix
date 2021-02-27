{ config, lib, pkgs, ... }:

with lib;

let
  nixpkgs = lib.cleanSource pkgs.path;

  channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}"
    { preferLocalBuild = true; }
    ''
      mkdir -p $out
      cp -prd ${nixpkgs.outPath} $out/nixos
      chmod -R u+w $out/nixos
      if [ ! -e $out/nixos/nixpkgs ]; then
        ln -s . $out/nixos/nixpkgs
      fi

      ln -s ${overlay}/mypkgs $out/nixos/overlay

      ${optionalString (config.system.nixos.revision != null) ''
        echo -n ${config.system.nixos.revision} > $out/nixos/.git-revision
      ''}
      echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
      echo ${config.system.nixos.versionSuffix} | sed -e s/pre// > $out/nixos/svn-revision

      cat <<EOF > $out/nixos/default.nix
      { overlays ? [] }@ args:
      import ./pkgs/top-level/impure.nix ( args // { overlays = overlays ++ [ ( import ./overlay ) ]; } )
      EOF

      ln -s ${builtins.fetchTarball "https://nixos.org/channels/nixos-${config.system.nixos.release}/nixexprs.tar.xz" }/programs.sqlite $out/nixos/
    '';

  overlay = builtins.fetchGit {
      url = "file://${toString ../.}";
      ref = "master";
  };

in

{
  system.activationScripts = {
    channel = ''
      echo "unpacking the NixOS/Nixpkgs sources..."
      mkdir -p /nix/var/nix/profiles/per-user/root
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/per-user/root/channels -i ${channelSources} --quiet --option build-use-substitutes false
    '';
  };
}

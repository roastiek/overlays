{
  description = "A basic flake with a shell";

  #inputs.nixpkgs.url = "git+file:///home/bobo/nixos/nixpkgs";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    #inputs.systems.follows = "systems";
  };
  #inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  #inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nix-vscode-extensions,
      nixpkgs,
      flake-utils,
      # rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            nix-vscode-extensions.overlays.default
            (import ./golang-overlay.nix)
            (import ./python-overlay.nix)
            # (import rust-overlay)
          ];
        };

        inherit (pkgs)
          vscode-with-extensions
          vscode-marketplace
          vscode-marketplace-release
          open-vsx
          open-vsx-release
          mnemebrain-lite
          ;

        vscode = vscode-with-extensions.override {
          vscodeExtensions = (
            with vscode-marketplace-release;
            [
              #github.copilot
              github.copilot-chat

              mkhl.direnv
              jnoortheen.nix-ide
              ms-vscode.makefile-tools
              # redhat.vscode-yaml

              raillyhugo.one-hunter

              # golang
              miguelsolorio.symbols
              vscode-marketplace-release.golang.go
              vscode-marketplace-release.casualjim.gotemplate
            ]
          );
        };

        packages.default = [
          vscode
          vscode
          pkgs.bashInteractive
          pkgs.ripgrep
          pkgs.openssl
          pkgs.buildah
        ];

        packages.go =
          packages.default
          ++ (with pkgs; [
            go_latest
            gopls
            delve
            golangci-lint
            gotools
            protobuf
          ]);

        packages.python =
          packages.default
          ++ (with pkgs; [
            python313
            uv-fhs

            #rust-bin.stable.latest.default
          ]);

        packages.gopython = packages.go ++ packages.python;

      in
      {
        inherit pkgs;
        packages.mnemebrain = mnemebrain-lite;
      }
      // {
        devShells = builtins.mapAttrs (
          set: packages:
          pkgs.mkShell {
            inherit packages;
            shellHook = ''
              # export NIXOS_OZONE_WL=0
              # export UV_NO_BINARY_PACKAGE=ruff
            '';
          }
        ) packages;
      }
    );
}

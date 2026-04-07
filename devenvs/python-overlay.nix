self: super: {
  uv-fhs = let
    uv = self.buildFHSEnv {
      inherit (super.uv) pname version;
      targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
      runScript = "${super.uv}/bin/uv";
    };
    uvx = self.buildFHSEnv {
      inherit (super.uv) pname version;
      targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
      runScript = "${super.uv}/bin/uvx";
      executableName = "uvx";
    };
  in self.symlinkJoin {
    inherit (super.uv) name pname version;
    paths = [ uv uvx super.uv ];
  };
}

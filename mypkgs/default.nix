self: super:
let
  inherit (super) callPackage;
  inherit (super) recurseIntoAttrs buildFHSUserEnv;
in rec {

  opera12 = callPackage ./opera12 {};

  freetype_subpixel = super.freetype.overrideDerivation (old: {
      postPatch = ''
        sed -r -i 's/^#define TT_CONFIG_OPTION_SUBPIXEL_HINTING .*$//' devel/ftoption.h include/freetype/config/ftoption.h
      '';
    });

  tango-extras-icon-theme = callPackage ./tango-extras-icon-theme {};

  debootstrap = super.debootstrap.overrideAttrs (oldAttrs: rec {
    buildInputs = [ self.gnupg1 ];
  });

  yed = callPackage ./yed {};

  goenvtemplator = callPackage ./goenvtemplator {};

  firefoxFHS = buildFHSUserEnv {
    name = "firefox";
    targetPkgs = pkgs: (with pkgs; [ chrome-gnome-shell firefox dbus ]);
    runScript = "firefox";
  };

  wine = super.winePackages.unstable;

  volume-mixer = callPackage ./volume-mixer {};

  lxc-templates = callPackage ./lxc-templates {};

  vscodium = super.vscodium.overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      p=$(cat $out/lib/vscode/resources/app/product.json)
      echo "$p" | ${self.jq}/bin/jq ' . + { "checksumFailMoreInfoUrl": "https://go.microsoft.com/fwlink/?LinkId=828886" }' > $out/lib/vscode/resources/app/product.json
      for s in $(find $out -name "*.js" -print); do
        substituteInPlace "$s" --replace 'sensitivity:"base"' 'sensitivity:"base",ignorePunctuation:1'
      done
    '';
  });
}

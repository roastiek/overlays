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
    buildInputs = oldAttrs.buildInputs ++ [ self.gnupg1 ];
  });

  #ecj = super.ecj.override { gtk2 = gtk3; webkitgtk2 = webkitgtk; };
  #jdtsdk = super.jdtsdk.override { gtk2 = gtk3; };
  #eclipses = recurseIntoAttrs (callPackage <nixpkgs/pkgs/applications/editors/eclipse> { gtk2 = self.gtk3; webkitgtk24x-gtk2 = self.webkitgtk; });

  #eclipse = with super.eclipses; eclipseWithPlugins {
  #  eclipse = eclipse-platform;
  #  plugins = with plugins; [ cdt jdt ];
  #};

  openjdk8_clean = (super.openjdk8.override { enableGnome2 = false; }).overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ self.xorg.libXrandr ];
    passthru = {
      inherit (super) architecture;
      home = "${openjdk8_clean}/lib/openjdk";
    };
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
}

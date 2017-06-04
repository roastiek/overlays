self: super:
with super; {

  opera12 = callPackage ./opera12 {};

  freetype_subpixel = freetype.override {
    useEncumberedCode = true;
    useInfinality = false;
  };

  qt48gtk = qt48.override {
    gtkStyle = true;
  };

  aspellDictDir = aspell.overrideAttrs (oldAttrs: rec {
    patchPhase = oldAttrs.patchPhase + ''
      patch -p1 < ${./aspell/dict-dir-from-nix-profiles.patch}
    '';
  });

  liberation1_ttf = callPackage ./liberation-fonts1 {};

  tango-extras-icon-theme = callPackage ./tango-extras-icon-theme {};

  clementine = super.clementine.override {
    libplist = null;
    libgpod = null;
    usbmuxd = null;
  };

  debootstrap = super.debootstrap.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ [ gnupg1 ];
  });

  utillinuxServices = super.utillinux.overrideAttrs (oldAttrs: rec {
    configureFlags = oldAttrs.configureFlags + ''
      --with-systemdsystemunitdir=''${bin}/lib/systemd/system/
    '';
  });

  #ecj = super.ecj.override { gtk2 = gtk3; webkitgtk2 = webkitgtk; };
  #jdtsdk = super.jdtsdk.override { gtk2 = gtk3; };
  #eclipses = recurseIntoAttrs (callPackage <nixpkgs/pkgs/applications/editors/eclipse> { gtk2 = gtk3; webkitgtk2 = webkitgtk; });

  #eclipse = with super.eclipses; eclipseWithPlugins {
  #  eclipse = eclipse-platform;
  #  plugins = with plugins; [ cdt jdt ];
  #};

}

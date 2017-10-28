self: super:
with super; rec {

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

  aspellWithDicts = callPackage ./aspell/aspell-with-dicts.nix {
    aspellDicts = [ aspellDicts.cs aspellDicts.en ];
  };

  liberation1_ttf = callPackage ./liberation-fonts1 {};

  tango-extras-icon-theme = callPackage ./tango-extras-icon-theme {};

  clementine = super.clementine.override {
    qt4 = qt48gtk;
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

  ecj = super.ecj.override { gtk2 = gtk3; webkitgtk2 = webkitgtk; };
  jdtsdk = super.jdtsdk.override { gtk2 = gtk3; };
  eclipses = recurseIntoAttrs (callPackage <nixpkgs/pkgs/applications/editors/eclipse> { gtk2 = gtk3; webkitgtk2 = webkitgtk; });

  #eclipse = with super.eclipses; eclipseWithPlugins {
  #  eclipse = eclipse-platform;
  #  plugins = with plugins; [ cdt jdt ];
  #};

  openjdk8_clean = (super.openjdk8.override { enableGnome2 = false; }).overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ xorg.libXrandr ];
    passthru = {
      inherit (pkgs)architecture;
      home = "${openjdk8_clean}/lib/openjdk";
    };
  });

  keepassxc = callPackage ./keepassxc {};

  yed = callPackage ./yed {};

  python-grpc = callPackage ./python-grpc {
    pythonPackages = python35Packages;
    protobuf = python-protobuf3_3;
  };

  protobuf3_3 = lib.overrideDerivation (callPackage <nixpkgs/pkgs/development/libraries/protobuf/generic-v3.nix> {
    version = "3.3.0";
    sha256 = "1258yz9flyyaswh3izv227kwnhwcxn4nwavdz9iznqmh24qmi59w";
  }) (attrs: { NIX_CFLAGS_COMPILE = "-Wno-error"; });

  python-protobuf3_3 = callPackage <nixpkgs/pkgs/development/python-modules/protobuf.nix> {
    inherit (python35Packages) python buildPythonPackage google_apputils pyext;
    disabled = false;
    doCheck = false;
    protobuf = protobuf3_3;
  };

  streamlink__ = super.streamlink.overrideAttrs ( oldAttrs: rec {
    version = "0.8.1";
    name = "streamlink-${version}";

    src = fetchFromGitHub {
      owner = "streamlink";
      repo = "streamlink";
      rev = "${version}";
      sha256 = "0l09vp108dw6d9d9rri2xwlr49mr5nkrlxbivr4kk5jbaczjp9xm";
    };

    STREAMLINK_USE_PYCOUNTRY="1";
    doCheck = false;

    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ ( with super.python3Packages;[ websocket_client pycountry pysocks ]);
  });

  properties-cpp = callPackage ./properties-cpp {};

  process-cpp = callPackage ./process-cpp {};

  libdbus-cpp = callPackage ./libdbus-cpp {};

  anbox = callPackage ./anbox {};
}

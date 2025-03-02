self: super:
let
  inherit (self) callPackage;
  inherit (super) recurseIntoAttrs buildFHSUserEnv;
in rec {

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

  # volume-mixer = callPackage ./volume-mixer {};

  lxc-templates = callPackage ./lxc-templates {};

  # vscodium = super.vscodium.overrideAttrs (oldAttrs: {
  #   installPhase = oldAttrs.installPhase + ''
  #     p=$(cat $out/lib/vscode/resources/app/product.json)
  #     echo "$p" | ${self.jq}/bin/jq ' . + { "checksumFailMoreInfoUrl": "https://go.microsoft.com/fwlink/?LinkId=828886" }' > $out/lib/vscode/resources/app/product.json
  #     for s in $(find $out -name "*.js" -type f -print); do
  #       substituteInPlace "$s" --replace 'sensitivity:"base"' 'sensitivity:"base",ignorePunctuation:!0' \
  #         --replace 'sensitivity:"accent"' 'sensitivity:"accent",ignorePunctuation:!0'
  #     done
  #   '';
  # });

  intel-undervolt = callPackage ./intel-undervolt { };

  freetype29 = callPackage ./freetype { };

  # freetype = freetype29;

  atomicparsley2 = with super; stdenv.mkDerivation {
    name = "atomicparsley";

    src = fetchFromGitHub {
      owner = "wez";
      repo = "atomicparsley";
      rev = "20200701.154658.b0d6223";
      sha256 = "1kym2l5y34nmbrrlkfmxsf1cwrvch64kb34jp0hpa0b89idbhwqh";
    };

    postPatch = ''
      substituteInPlace CMakeLists.txt --replace '3.17' '3.16'
    '';

    buildInputs = [ cmake zlib ];

    installPhase = ''
      ls
      mkdir -p $out/bin
      cp AtomicParsley $out/bin
    '';
  };

  kube-login = self.callPackage ./kube-login { };

  vivaldi = super.vivaldi.override ({ proprietaryCodecs = true; enableWidevine = true; });

  # vw = self.stdenv.mkDerivation {
  #   name = "vw";

  #   src = self.fetchFromGitHub {
  #     owner = "VowpalWabbit";
  #     repo = "vowpal_wabbit";
  #     rev = "8.10.2";
  #     sha256 = "1f5cps9md0c5nrk3c0q1q94lqi3g64f2h493a408zlj1c1ks754l";
  #     fetchSubmodules = true;
  #   };

  #   buildInputs = with self; [ boost zlib ];

  #   nativeBuildInputs = with self; [ cmake help2man ];

  #   #configureFlags = with self; [ "--with-boost-libdir=${boost.out}/lib" ];
  # };

  boostStatic = self.boost.override { enableShared = false; enableStatic = true; };

    glibcSt = self.runCommand "glibc" {} ''
      mkdir -p $out/lib
      ln -s ${self.glibc.static}/lib/libpthread.a $out/lib/
      ln -s ${self.glibc.static}/lib/libc.a $out/lib/
      ln -s ${self.glibc.static}/lib/libm.a $out/lib/
    '';

  vw = self.stdenv.mkDerivation {
    name = "vw";

    src = self.fetchFromGitHub {
      owner = "VowpalWabbit";
      repo = "vowpal_wabbit";
      rev = "9.10.0";
      fetchSubmodules = true;
      sha256 = "sha256-HKxhEB4ph2tOWgvYngYTcv0OCMISj3KqZpP2zsEUPs0=";
    };

    postPatch = ''
      substituteInPlace vowpalwabbit/c_wrapper/CMakeLists.txt \
        --replace-fail 'SHARED_ONLY' 'STATIC_OR_SHARED'
    '';

    nativeBuildInputs = with self; [ cmake ];
    buildInputs = with self; [ boost zlib perl ];   #spdlog rapidjson ];
    enableParallelBuilding = true;
    cmakeFlags = [
      "-DFMT_SYS_DEP=OFF"
      "-DSPDLOG_SYS_DEP=OFF"
      "-DRAPIDJSON_SYS_DEP=OFF"
      "-DVW_INSTALL=ON"
      # "-DSTATIC_LINK_VW=ON"
    ];
    #configureFlags = with self; [ "--with-boost-libdir=${boost.out}/lib" "--enable-static" ];

    # postInstall = ''
    #   cp ../vowpalwabbit/io/* $out/include/vw/io
    #   cp -r ../ext_libs/spdlog/include/spdlog/fmt/bundled $out/include/spdlog/fmt/
    #   cp ../utl/vw-varinfo $out/bin
    # '';
  };

  vw-deps = self.symlinkJoin {
    name = "vw-deps";
    paths = with self; [ vw boost boost.dev zlib ]; #boostStatic boostStatic.dev zlib ];
  };

  # gnomeExtensions = super.gnomeExtensions // {
  #   vitals = self.callPackage ./vitals { };
  #   volume-mixer = self.callPackage ./volume-mixer { };
  #   no-title-bar = super.gnomeExtensions.no-title-bar.overrideAttrs (oldAttrs: {
  #     postInstall = ''
  #       substituteInPlace $out/share/gnome-shell/extensions/no-title-bar@jonaspoehler.de/metadata.json --replace '"3.38"' '"43"'
  #     '';
  #   });
  # };

  # thermald = super.thermald.overrideAttrs ( oldAttrs: rec {
  #   version = "2.4.6";
  #   src = self.fetchFromGitHub {
  #     owner = "intel";
  #     repo = "thermal_daemon";
  #     rev = "v${version}";
  #     sha256 = "1lgaky8cmxbi17zpymy2v9wgknx1g92bq50j6kfpsm8qgb7djjb6";
  #   };
  #   CFLAGS="-Wno-error";

  #   outputs = ["out"];

  #   buildFlags = [ "CFLAGS=-Wno-error" "CXXFLAGS=-Wno-error" ];
  #   # configureFlags = oldAttrs.configureFlags ++ [
  #   #   "--help"
  #   #   "--disable-error-on-warning"
  #   # ];

  #   buildInputs =  oldAttrs.buildInputs ++ [ self.xz ];

  #   preConfigure = ''
  #     echo PKG_CONFIG_PATH=$PKG_CONFIG_PATH
  #   '';

  #   postInstall = ''
  #     mkdir -p $out/etc/thermald
  #     ${oldAttrs.postInstall}
  #   '';
  # });

  thermald = self.stdenv.mkDerivation rec {
    pname = "thermald";
    version = "2.4.6";

    outputs = [ "out" "devdoc" ];

    src = self.fetchFromGitHub {
      owner = "intel";
      repo = "thermal_daemon";
      rev = "v${version}";
      sha256 = "1lgaky8cmxbi17zpymy2v9wgknx1g92bq50j6kfpsm8qgb7djjb6";
    };

    nativeBuildInputs = with self; [
      autoconf
      autoconf-archive
      automake
      docbook-xsl-nons
      docbook_xml_dtd_412
      gtk-doc
      libtool
      pkg-config
    ];

    buildInputs = with self; [
      dbus
      dbus-glib
      libevdev
      libxml2
      xz
      upower
    ];

    configureFlags = [
      "--sysconfdir=${placeholder "out"}/etc"
      "--localstatedir=/var"
      "--enable-gtk-doc"
      "--with-dbus-sys-dir=${placeholder "out"}/share/dbus-1/system.d"
      "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
      "--disable-werror"
    ];

    preConfigure = "NO_CONFIGURE=1 ./autogen.sh";

    postInstall = ''
      cp ./data/thermal-conf.xml $out/etc/thermald/
    '';

    meta = with self.lib; {
      description = "Thermal Daemon";
      homepage = "https://github.com/intel/thermal_daemon";
      changelog = "https://github.com/intel/thermal_daemon/blob/master/README.txt";
      license = licenses.gpl2Plus;
      platforms = [ "x86_64-linux" "i686-linux" ];
      maintainers = with maintainers; [ abbradar ];
    };
  };

  thermal-monitor = self.libsForQt5.callPackage ./tm { };

  gnome = super.gnome // rec {
    mutter = super.gnome.mutter.overrideAttrs ( oldAttrs: { patches = ( oldAttrs.patches or [] ) ++ [ ./mutter.patch ]; });
    gnome-shell = super.gnome.gnome-shell.override { inherit mutter; };
  };

  qsync = self.libsForQt512.callPackage ./qsync {};

  binance = self.callPackage ./binance {};

  solaar = super.solaar.overrideAttrs ( oldAttrs: {
    postInstall = oldAttrs.postInstall + ''
      substituteInPlace $out/share/applications/solaar.desktop --replace 'Exec=solaar' 'Exec=solaar --window=hide'
    '';
  });

  snappers = self.callPackage ./snappers { pythonPackages = self.python3Packages; };

  piggy = self.callPackage ./piggy { };

  # gopls = self.buildGoModule rec {
  #   pname = "gopls";
  #   version = "0.14.2";
  #   src = self.fetchFromGitHub {
  #     owner = "golang";
  #     repo = "tools";
  #     rev = "gopls/v${version}";
  #     sha256 = "sha256-hcicI5ka6m0W2Sj8IaxNsLfIc97eR8SKKp81mJvM2GM=";
  #   };

  #   modRoot = "gopls";
  #   vendorHash = "sha256-jjUTRLRySRy3sfUDfg7cXRiDHk1GWHijgEA5XjS+9Xo=";
  #   doCheck = false;

  #   # Only build gopls, and not the integration tests or documentation generator.
  #   subPackages = [ "." ];
  # };

}

self: super:
let
  inherit (self) callPackage;
  inherit (super) recurseIntoAttrs buildFHSUserEnv;
in rec {

  opera12 = callPackage ./opera12 { freetype = freetype29;
    inherit (super.gst_all_1) gstreamer gst-plugins-base gst-plugins-good;
  };

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

  vw = self.stdenv.mkDerivation {
    name = "vw";

    src = self.fetchFromGitHub {
      owner = "VowpalWabbit";
      repo = "vowpal_wabbit";
      rev = "9.0.1";
      fetchSubmodules = true;
      sha256 = "sha256-4Ye+tsJ0zfScDTAO/cckgyTs2j1ihkl72tSglBkCMG0=";
    };

    postPatch = ''
      substituteInPlace ext_libs/spdlog/cmake/spdlog.pc.in \
        --replace '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
    '';

    nativeBuildInputs = with self; [ cmake ];
    buildInputs = with self; [ boost zlib ]; #spdlog rapidjson ];
    enableParallelBuilding = true;
    cmakeFlags = [
      "-DFMT_SYS_DEP=OFF"
      "-DSPDLOG_SYS_DEP=OFF"
      "-DRAPIDJSON_SYS_DEP=OFF"
      # "-DSTATIC_LINK_VW=ON"
    ];
    #configureFlags = with self; [ "--with-boost-libdir=${boost.out}/lib" "--enable-static" ];

    postInstall = ''
      cp ../vowpalwabbit/io/* $out/include/vowpalwabbit/io
      cp -r ../ext_libs/spdlog/include/spdlog/fmt/bundled $out/include/spdlog/fmt/
    '';
  };

  vw-deps = self.symlinkJoin {
    name = "vw-deps";
    paths = with self; [ vw boost boost.dev zlib ]; #boostStatic boostStatic.dev zlib ];
  };

  gnomeExtensions = super.gnomeExtensions // {
    vitals = self.callPackage ./vitals { };
    volume-mixer = self.callPackage ./volume-mixer { };
    no-title-bar = super.gnomeExtensions.no-title-bar.overrideAttrs (oldAttrs: {
      postInstall = ''
        substituteInPlace $out/share/gnome-shell/extensions/no-title-bar@jonaspoehler.de/metadata.json --replace '"3.38"' '"43"'
      '';
    });
  };

  thermald = super.thermald.overrideAttrs ( oldAttrs: rec {
    version = "2.4.6";
    src = self.fetchFromGitHub {
      owner = "intel";
      repo = "thermal_daemon";
      rev = "v${version}";
      sha256 = "1lgaky8cmxbi17zpymy2v9wgknx1g92bq50j6kfpsm8qgb7djjb6";
    };
  });

  thermal-monitor = self.libsForQt5.callPackage ./tm { };

  gnome = super.gnome // rec {
    mutter = super.gnome.mutter.overrideAttrs ( oldAttrs: { patches = oldAttrs.patches ++ [ ./mutter.patch ]; });
    gnome-shell = super.gnome.gnome-shell.override { inherit mutter; };
  };

  qsync = self.libsForQt512.callPackage ./qsync {};

  binance = self.callPackage ./binance {};

  solaar = super.solaar.overrideAttrs ( oldAttrs: {
    postInstall = oldAttrs.postInstall + ''
      substituteInPlace $out/share/applications/solaar.desktop --replace 'Exec=solaar' 'Exec=solaar --window=hide'
    '';
  });

}

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

  vscodium = super.vscodium.overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      p=$(cat $out/lib/vscode/resources/app/product.json)
      echo "$p" | ${self.jq}/bin/jq ' . + { "checksumFailMoreInfoUrl": "https://go.microsoft.com/fwlink/?LinkId=828886" }' > $out/lib/vscode/resources/app/product.json
      for s in $(find $out -name "*.js" -print); do
        substituteInPlace "$s" --replace 'sensitivity:"base"' 'sensitivity:"base",ignorePunctuation:1'
      done
    '';
  });

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

  kube-login = super.buildGoModule rec {
    pname = "kube-login";
    version = "1.2.12";

    subPackages = [ "." ];

    src = builtins.fetchGit {
      url = "git@gitlab.seznam.net:ultra/SCIF/k8s/kube-login.git";
      ref = version;
    };

    overrideModAttrs = oldAttrs: oldAttrs // {
      preConfigure = ''
        HOME=/build/pkger pkger
      '';

      postInstall = ''
        cp pkged.go $out/
      '';
    };

    vendorSha256 = "sha256:00g9yw5dg392yxc771f1x40b7w89v5syynpcdnin3qqsx7avvv1w";

    nativeBuildInputs = [ super.pkger ];

    postConfigure = ''
      cp vendor/pkged.go .
    '';
  };

  vivaldi = super.vivaldi.override ({ proprietaryCodecs = true; enableWidevine = true; });

  vw = self.stdenv.mkDerivation {
    name = "vw";

    src = self.fetchFromGitHub {
      owner = "VowpalWabbit";
      repo = "vowpal_wabbit";
      rev = "8.10.2";
      sha256 = "1f5cps9md0c5nrk3c0q1q94lqi3g64f2h493a408zlj1c1ks754l";
      fetchSubmodules = true;
    };

    buildInputs = with self; [ boost zlib ];

    nativeBuildInputs = with self; [ cmake help2man ];

    #configureFlags = with self; [ "--with-boost-libdir=${boost.out}/lib" ];
  };

  gnomeExtensions = super.gnomeExtensions // {
    vitals = self.callPackage ./vitals { };
  };

}

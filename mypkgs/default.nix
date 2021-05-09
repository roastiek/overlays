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


  alsa-sof-firmware = callPackage ./alsa-sof-firmware {};

  # alsa-ucm-conf = callPackage ./alsa-ucm-conf {};

  # alsa-topology-conf = callPackage ./alsa-topology-conf {};

  # alsa-lib = callPackage ./alsa-lib {};

  pulseaudio99Full = callPackage ./pulseaudio {
    inherit (self.gnome3) dconf;
    inherit (self.darwin.apple_sdk.frameworks) CoreServices AudioUnit Cocoa;
    alsaLib = self.alsaLib;
    x11Support = true;
    jackaudioSupport = true;
    airtunesSupport = true;
    bluetoothSupport = true;
    remoteControlSupport = true;
    zeroconfSupport = true;
  };

  pulseaudio-modules-bt = super.pulseaudio-modules-bt.override {
    pulseaudio = self.pulseaudio99Full;
  };

  intel-undervolt = callPackage ./intel-undervolt { };

  freetype29 = callPackage ./freetype { };

  # firmwareLinuxNonfree = callPackage ./firmware-linux-nonfree { };

  # freetype = freetype29;

  # tageditor = callPackage ./tageditor { };

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
    version = "1.2.8";

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

    vendorSha256 = "sha256:0aqib09mi4l2n9xaq9by5va95pamx5kxn2b7i7qzkqmcannpiaj3";

    nativeBuildInputs = [ super.pkger ];

    postConfigure = ''
      cp vendor/pkged.go .
    '';
  };

  vivaldi = super.vivaldi.override ({ proprietaryCodecs = true; enableWidevine = true; });

}

self: super:
let
  inherit (self) callPackage;
  inherit (super) recurseIntoAttrs buildFHSUserEnv;
in rec {

  opera12 = callPackage ./opera12 { freetype = freetype29; };

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

  linux_5_5 = let
    kernelPatches = callPackage ./kernel/patches.nix { };
  in callPackage ./kernel/linux-5.5.nix {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export_kernel_fpu_functions."5.3"
    ];
  };

  linuxPackages_5_5 = recurseIntoAttrs (super.linuxPackagesFor self.linux_5_5);

  linux_5_6 = let
    kernelPatches = callPackage ./kernel/patches.nix { };
  in callPackage ./kernel/linux-5.6.nix {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export_kernel_fpu_functions."5.3"
    ];
  };

  linuxPackages_5_6 = ( recurseIntoAttrs (super.linuxPackagesFor self.linux_5_6) ) // { wireguard = null; };

  alsa-sof-firmware = callPackage ./alsa-sof-firmware {};

  alsa-ucm-conf = callPackage ./alsa-ucm-conf {};

  alsa-topology-conf = callPackage ./alsa-topology-conf {};

  alsa-lib = callPackage ./alsa-lib {};

  pulseaudio99Full = callPackage ./pulseaudio {
    inherit (self.gnome3) dconf;
    inherit (self.darwin.apple_sdk.frameworks) CoreServices AudioUnit Cocoa;
    alsaLib = self.alsa-lib;
    x11Support = true;
    jackaudioSupport = true;
    airtunesSupport = true;
    bluetoothSupport = true;
    remoteControlSupport = true;
    zeroconfSupport = true;
  };

  intel-undervolt = callPackage ./intel-undervolt { };

  # firmwareLinuxNonfree = callPackage ./firmware-linux-nonfree { };

  freetype29 = callPackage ./freetype { };

  # freetype = freetype29;
}

self: super:
{
  alsa1_2_14 = let 
    callPackage = drv: args: self.lib.callPackageWith (self // self.alsa1_2_14) drv args;
  in {
    alsa-topology-conf = callPackage ./alsa-topology-conf/package.nix {};
    alsa-ucm-conf = callPackage ./alsa-ucm-conf/package.nix {};
    alsa-lib = callPackage ./alsa-lib/package.nix {};
    
    pipewire = super.pipewire.override { inherit (self.alsa1_2_14) alsa-lib; };
    wireplumber = super.wireplumber.override { inherit (self.alsa1_2_14) pipewire; };
  };

  sof-firmware = self.callPackage ./sof-firmware/package.nix {};
}
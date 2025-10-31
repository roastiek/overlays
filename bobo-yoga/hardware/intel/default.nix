super: self:
{
  linux-firmware = self.linux-firmware.overrideAttrs (oldAttrs: {
    postInstall = '' 
      rm $out/lib/firmware/intel/ish/ish_lnlm.bin
      cp ${./ish_lnlm.bin} $out/lib/firmware/intel/ish/ish_lnlm.bin
    '';
  });  
}
self: super: {
  go_latest = super.go_1_26;
  buildGoModule = super.buildGo126Module;
  buildGoLatestModule = super.buildGo126Module;
  buildGo125Module = super.buildGo126Module;

  # delve = super.delve.overrideAttrs (oldAttrs: rec {
  #   version = "1.26.1";
  #   src = self.fetchFromGitHub {
  #     owner = "go-delve";
  #     repo = "delve";
  #     rev = "v${version}";
  #     hash = "sha256-j/uGkAd/4Hpspgcb2J3UOs8iThx2YydUee31Hddl9zw=";
  #   };
  # });
}

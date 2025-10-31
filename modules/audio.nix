{ config, lib, pkgs, ... }:
{
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          # "default.clock.rate"          = 192000;
          "default.clock.allowed-rates" = [ 48000 44100 88200 96000 192000 ];
        };
      };
      "11-high-quality-resample" = {
        "stream.properties" = {
           "resample.quality" = 10;
        };
      };
    };
    wireplumber.extraConfig = {
      # "log-level-debug" = {
      #   "context.properties" = {
      #     # Output Debug log messages as opposed to only the default level (Notice)
      #     "log.level" = "D";
      #   };
      # };

      "a80-channel-swap" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_output.usb-EDIFIER_AIRPULSE_A80-00.analog-stereo";
              }
            ];
            actions = {
              update-props = {
                "audio.position" = "FR,FL";
                "audio.rate" = 96000;
              };
            };
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
  ];

}
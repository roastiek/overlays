{ config, lib, pkgs, ... }:
{
  programs.dconf.profiles = {
    user.databases = [
      { 
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
          };
        };
      }
    ];
  };

  environment.etc = {
    "xdg/monitors.xml" = {
      source = ./monitors.xml;
    };
  };
}
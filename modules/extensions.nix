{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    with pkgs.gnomeExtensions;
    [
      # gnome50Extensions."impatience@gfxmonk.net"
      appindicator
      gnome50Extensions."upower-battery@codilia.com"
      unblank
      no-titlebar-when-maximized
      vertical-workspaces
      astra-monitor
      gnome-shell-extensions

      bluetooth-battery-meter
      preserve-battery-health
      custom-reboot
      papershell
      restart-to
    ];

  services.desktopManager.gnome.sessionPath = with pkgs; [ libgtop ];
}

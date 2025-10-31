{ config, lib, pkgs, ... }:
{
  services.snapper = {
    snapshotInterval = "*-*-* *:0/15:00";
    cleanupInterval = "1h";
    configs = {
      home = {
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = "28800";
        TIMELINE_LIMIT_HOURLY = "0-48";
        TIMELINE_LIMIT_DAILY = "0-14";
        TIMELINE_LIMIT_WEEKLY = "0-8";
        TIMELINE_LIMIT_MONTHLY = "0-3";
        TIMELINE_LIMIT_YEARLY = "0-2";
        SYNC_ACL = "yes";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    snappers
  ];

}
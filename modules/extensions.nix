{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
    #impatience
    gnome45Extensions."impatience@gfxmonk.net"
    gnome45Extensions."noannoyance-fork@vrba.dev"
    appindicator
    no-overview
    upower-battery
    unblank
    ( no-title-bar.overrideAttrs ( oldAttrs: { patches = ( oldAttrs.patches or [] ) ++ [
        ../mypkgs/no-title-bar.patch
      ]; } ) )
    (resource-monitor.overrideAttrs ( oldAttrs: {
      src = fetchzip {
        url = "https://extensions.gnome.org/extension-data/${
            builtins.replaceStrings [ "@" ] [ "" ] "Resource_Monitor@Ory0n"
          }.v21.shell-extension.zip";
        sha256 = "sha256-g3iIxhx84sJ78GNkFApPh5S/KWQxpaayAX723BfON9c=";
        stripRoot = false;
        # The download URL may change content over time. This is because the
        # metadata.json is automatically generated, and parts of it can be changed
        # without making a new release. We simply substitute the possibly changed fields
        # with their content from when we last updated, and thus get a deterministic output
        # hash.
        postFetch = ''
          echo "ewogICJfZ2VuZXJhdGVkIjogIkdlbmVyYXRlZCBieSBTd2VldFRvb3RoLCBkbyBub3QgZWRpdCIsCiAgImRlc2NyaXB0aW9uIjogIk1vbml0b3IgdGhlIHVzZSBvZiBzeXN0ZW0gcmVzb3VyY2VzIGxpa2UgY3B1LCByYW0sIGRpc2ssIG5ldHdvcmsgYW5kIGRpc3BsYXkgdGhlbSBpbiBnbm9tZSBzaGVsbCB0b3AgYmFyLiIsCiAgImRvbmF0aW9ucyI6IHsKICAgICJwYXlwYWwiOiAiMHJ5MG4iCiAgfSwKICAiZ2V0dGV4dC1kb21haW4iOiAiY29tLWdpdGh1Yi1Pcnkwbi1SZXNvdXJjZV9Nb25pdG9yIiwKICAibmFtZSI6ICJSZXNvdXJjZSBNb25pdG9yIiwKICAic2V0dGluZ3Mtc2NoZW1hIjogImNvbS5naXRodWIuT3J5MG4uUmVzb3VyY2VfTW9uaXRvciIsCiAgInNoZWxsLXZlcnNpb24iOiBbCiAgICAiNDUiCiAgXSwKICAidXJsIjogImh0dHBzOi8vZ2l0aHViLmNvbS8wcnkwbi9SZXNvdXJjZV9Nb25pdG9yLyIsCiAgInV1aWQiOiAiUmVzb3VyY2VfTW9uaXRvckBPcnkwbiIsCiAgInZlcnNpb24iOiAyMQp9" | base64 --decode > $out/metadata.json
        '';
      };
      patches = ( oldAttrs.patches or [] ) ++ [
        ../mypkgs/resource-monitor/disk.patch
        ../mypkgs/resource-monitor/units.patch
        ../mypkgs/resource-monitor/autohide.patch
        ../mypkgs/resource-monitor/thermal.patch
        ../mypkgs/resource-monitor/freqs.patch
      ];
    }))
  ];
}

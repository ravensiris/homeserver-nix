{
  lib,
  config,
  ...
}:
with lib; {
  options.transmission.on-done = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "list of scripts to run on transmission's `script-torrent-done-filename`";
  };

  config = {
    # networking.firewall.allowedTCPPorts = [5030];

    services.caddy.virtualHosts."http://jellyfin.komorebi.lan".extraConfig = ''
      reverse_proxy :8096
    '';

    services.caddy.virtualHosts."http://torrent.komorebi.lan".extraConfig = ''
      reverse_proxy :9091
    '';

    services.caddy.virtualHosts."http://sonarr.komorebi.lan".extraConfig = ''
      reverse_proxy :8989
    '';

    services.caddy.virtualHosts."http://prowlarr.komorebi.lan".extraConfig = ''
      reverse_proxy :9696
    '';

    nixarr = {
      enable = true;
      mediaDir = "/data/media";
      stateDir = "/data/media.state/nixarr";

      transmission = {
        enable = true;
        flood.enable = true;
        openFirewall = true;
      };

      jellyfin = {
        enable = true;
        # openFirewall = true;
      };

      prowlarr = {
        enable = true;
        # openFirewall = true;
      };

      sonarr = {
        enable = true;
        # openFirewall = true;
      };
    };

    services.transmission.settings = {
      "script-torrent-done-enabled" = lib.mkForce true;
      "script-torrent-done-filename" = lib.mkForce (builtins.concatStringsSep ";" config.transmission.on-done);
    };
  };
}

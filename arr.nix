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
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

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
      };

      prowlarr = {
        enable = true;
      };

      sonarr = {
        enable = true;
      };
    };

    services.transmission.settings = {
      "script-torrent-done-enabled" = lib.mkForce true;
      "script-torrent-done-filename" = lib.mkForce (builtins.concatStringsSep ";" config.transmission.on-done);
    };
  };
}

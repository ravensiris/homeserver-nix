{...}: {
  services.caddy.virtualHosts."http://navidrome.komorebi.lan".extraConfig = ''
    route {
      @coverArt {
          path /rest/getCoverArt.view
      }

      handle @coverArt {
          rewrite * /rest/getCoverArt
      }

      reverse_proxy :4533
    }
  '';

  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/data/media/library/music";
    };
  };

  environment.persistence."/nix/persist".directories = [
    "/var/lib/navidrome"
  ];
}

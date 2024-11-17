{pkgs, ...}: {
  services.slskd = {
    enable = true;
    package = pkgs.unstable.slskd;
    domain = null;

    environmentFile = "/run/keys/slskd.env.secret";
    settings = {
      directories.downloads = "/data/soulseek";

      shares = {
        directories = ["/data/media/library/music"];
      };
    };
  };

  services.caddy.virtualHosts."http://slsk.komorebi.lan".extraConfig = ''
    reverse_proxy :5030
  '';

  environment.persistence."/nix/persist".directories = [
    "/var/lib/slskd/data"
  ];
}

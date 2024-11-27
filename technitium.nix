{...}: {
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/private/technitium-dns-server"
    ];
  };

  services.caddy.virtualHosts."http://dns.komorebi.lan".extraConfig = ''
    reverse_proxy :5380
  '';

  # fix containers trying to hit dockerhub/quay when DNS not ready yet
  systemd.services.docker = {
    after = ["technitium-dns.service"];
    wants = ["technitium-dns.service"];
  };
}

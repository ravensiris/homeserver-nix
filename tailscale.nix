{...}: {
  services.tailscale = {
    enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}

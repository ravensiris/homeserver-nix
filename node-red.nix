{...}: {
  services.node-red = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/node-red"
    ];
  };
}

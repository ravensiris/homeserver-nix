{...}: {
  services.caddy.virtualHosts."http://octoprint.komorebi.lan".extraConfig = ''
    reverse_proxy :5000
  '';

  services.octoprint = {
    enable = true;
  };
}

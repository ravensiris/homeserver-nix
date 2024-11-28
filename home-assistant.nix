{pkgs, ...}: let
  sources = {
    bambu = pkgs.fetchFromGitHub {
      owner = "greghesp";
      repo = "ha-bambulab";
      rev = "1ebaf4cdc84aebf6d5802baf6899a1ab9c41b01a";
      sha256 = "sha256-T3C90H354onzmlyIxmlQ7pCyinGmlb2FVTpumjhcDGU=";
    };
  };
in {
  services.caddy.virtualHosts."http://home.komorebi.lan".extraConfig = ''
    reverse_proxy :8123
  '';

  services.home-assistant = {
    enable = true;
    package = pkgs.unstable.home-assistant;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
      "shelly"
      "mikrotik"
      "jellyfin"
      "sonarr"
      "mqtt"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      http = {
        trusted_proxies = ["127.0.0.1"];
        use_x_forwarded_for = true;
      };
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = ["pattern readwrite #"];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [1883];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/hass"
    ];
  };

  systemd.tmpfiles.rules = [
    "C /var/lib/hass/custom_components/bambu_lab - - - - ${sources.bambu}/custom_components/bambu_lab"
    "Z /var/lib/hass/custom_components 770 hass hass - -"
  ];
}

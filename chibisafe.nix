{...}: {
  services.caddy.virtualHosts."http://chibi.ravensiris.xyz".extraConfig = ''
    route {
      file_server * {
          root /data/chibisafe/uploads/
          hide quarantine
          pass_thru
      }

      @api path /api/*
      reverse_proxy @api :8000 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
      }

      @docs path /docs*
      reverse_proxy @docs :8000 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
      }

      reverse_proxy :8001 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
      }
    }
  '';

  virtualisation.oci-containers.containers.chibisafe-server = {
    image = "chibisafe/chibisafe-server:latest";
    ports = ["8000:8000"];
    volumes = [
      "/data/chibisafe/database:/app/database:rw"
      "/data/chibisafe/uploads:/app/uploads:rw"
      "/data/chibisafe/logs:/app/logs:rw"
    ];
    # environmentFiles = ["/run/keys/strapi.env.secret"];
  };

  virtualisation.oci-containers.containers.chibisafe = {
    image = "chibisafe/chibisafe:latest";
    ports = ["8001:8001"];
    environment = {
      BASE_API_URL = "https://chibi.ravensiris.xyz";
    };
    # environmentFiles = ["/run/keys/strapi.env.secret"];
  };
}

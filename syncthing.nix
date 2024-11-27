{...}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings = {
      gui = {
        user = "overlord";
        password = "$2b$12$L6eKi.U9deqGE2KJWqFzUOrCbNtY.rTO2WktB3KA32OeUzT9yY.V.";
      };
      devices = {
        "steamdeck" = {id = "AP6PFUE-DQNMXZQ-GX23KY4-NYKKQIK-XH5OKES-IZM6EDU-HHSQZ3E-UMZIBQC";};
      };
      folders = {
        "Share" = {
          path = "/data/Share/Games";
          devices = ["steamdeck"];
        };
      };
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}

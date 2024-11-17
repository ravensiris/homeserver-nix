{
  lib,
  pkgs,
  config,
  ...
}: let
  dataDir = "/data/media.state";
  mediaDir = "/data/media";
in {
  # networking.firewall.allowedTCPPorts = [9393];

  users.groups.media.gid = 993;
  users.users.streamer.uid = 993;

  home-manager.users.q.programs.beets = {
    enable = true;
    settings = {
      directory = "/data/media/library/music/";
      library = "/data/media.state/betanin/beets/library.db";
      "import" = {
        move = false;
        hardlink = true;
      };
      scrub = {auto = true;};
      fetchart = {
        high_resolution = true;
      };
      badfiles = {
        check_on_import = true;
        commands = {
          flac = "${pkgs.flac}/bin/flac --silent --test";
          mp3 = "${pkgs.mp3val}/bin/mp3val -si";
        };
      };
      paths = {
        default = "$albumartist/$album%aunique{}/%if{$multidisc,Disc $disc/}$track $title";
      };
      item_fields = {
        multidisc = "1 if disctotal > 1 else 0";
      };
      plugins = lib.concatStringsSep " " ["inline" "embedart" "fetchart" "badfiles" "fish" "duplicates" "scrub"];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir}/betanin/data 755 beet media -"
    "d ${dataDir}/betanin/config 755 beet media -"
    "d ${dataDir}/betanin/beets 755 beet media -"
  ];

  virtualisation.oci-containers.containers.betanin = let
    imageFile = pkgs.dockerTools.buildImage {
      name = "betanin";
      tag = "latest";
      fromImage = pkgs.dockerTools.pullImage {
        imageName = "sentriz/betanin";
        imageDigest = "sha256:880d57edb58044ac9ef6e816a84380f3b92edec3d48714f50743765920835849";
        sha256 = "0kdrwrkvlapfy5djkq2j7njzfryjhzszyls4l5c1i097zbjv4m0p";
        finalImageName = "sentriz/betanin";
        finalImageTag = "latest";
      };
    };
  in {
    image = "sentriz/betanin";
    imageFile = imageFile;
    ports = ["9393:9393"];
    volumes = [
      "${dataDir}/betanin/data:/b/.local/share/betanin/"
      "${dataDir}/betanin/config:/b/.config/betanin/"
      "${dataDir}/betanin/beets:/b/.config/beets/"
      # TODO: these are dependant on `arr.nix`
      # too lazy to fix this for now
      "${mediaDir}/library/music:/b/Music/"
      "${mediaDir}/torrents:/downloads/"
      # END TODO
    ];
    environment = {
      UID = toString config.users.users.streamer.uid;
      GID = toString config.users.groups.media.gid;
    };
    # environmentFiles = ["/run/keys/.env.secret"];
  };

  transmission.on-done = let
    betaninScript = pkgs.writeShellScriptBin "torrent-finished.sh" ''
      ${pkgs.curl}/bin/curl \
          --request POST \
          --data-urlencode "path=/downloads" \
          --data-urlencode "name=$TR_TORRENT_NAME" \
          --header "X-API-Key: 2dc4133d3f27ba5021fb8786e94d6bed" \
          "http://127.0.0.1:9393/api/torrents"
    '';
  in ["${betaninScript}/bin/torrent-finished.sh"];

  systemd.services."${config.virtualisation.oci-containers.backend}-betanin".serviceConfig.ExecStartPre = let
    startupScript = pkgs.writeShellScriptBin "start-pre.sh" ''
      rm /data/media.state/betanin/beets/config.yaml
      ln -s $(${pkgs.coreutils}/bin/realpath /home/q/.config/beets/config.yaml) /data/media.state/betanin/beets/config.yaml
    '';
  in
    lib.mkBefore [
      "${startupScript}/bin/start-pre.sh"
    ];
}

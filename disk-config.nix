{
  lib,
  disks ? ["/dev/disk/by-id/ata-CT500MX500SSD4_2007E28AE330"],
  ...
}: {
  disko.devices = {
    disk = lib.genAttrs disks (dev: {
      device = dev;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            label = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          nix = {
            label = "NIX";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
        };
      };
    });

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };
  };
}

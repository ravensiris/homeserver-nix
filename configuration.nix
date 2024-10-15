{
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      (import ./disk-config.nix {
        inherit lib;
        disks = ["/dev/disk/by-id/ata-CT500MX500SSD4_2007E28AE330"];
      })
    ]
    ++ lib.optionals (!lib.inPureEvalMode) ["${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"];

  environment.persistence."/nix/persist" = {
    enable = true; # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/libvirt"
      "/var/lib/docker"
    ];
    files = [
      # "/etc/machine-id"
    ];
  };

  programs.fuse.userAllowOther = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "komorebi";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  users.users.q = {
    isNormalUser = true;
    description = "q";
    extraGroups = ["networkmanager" "wheel"];
    # packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    neovim
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."root".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4duy6jXTVgjst3f9zHNMKxWodvXc2aN1JV0uh/9Zyi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9Al4LsSHmhaZ75PPycON6ifkumNoTWAWRMue+6hwMx"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOFhn5qz3k6kIgTkMTN4k75Fss0THO9CHZFCyc9jIgd2N/s9Oyl1YdOvG850sJf/zVqYXmZ74HzMANqsAA5XTgw="
  ];

  system.stateVersion = "24.05";
}

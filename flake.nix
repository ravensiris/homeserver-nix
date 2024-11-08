{
  description = "homeserver nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    nixarr.url = "github:rasmus-kirk/nixarr";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    nixpkgs,
    impermanence,
    disko,
    nixarr,
    nixpkgs-unstable,
    home-manager,
    ...
  }: let
    unstableOverlay = final: prev: {
      unstable = nixpkgs-unstable.legacyPackages.${prev.system};
    };
    unstableModule = {
      config,
      pkgs,
      ...
    }: {nixpkgs.overlays = [unstableOverlay];};
  in {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      };

      # NOTE: yes. it's named like that due to the annoying RGB default settings.
      komorebi = {
        deployment = {
          targetHost = "192.168.88.35";
          buildOnTarget = true;
        };

        deployment.keys."slskd.env.secret".keyCommand = ["pass" "slskd-env"];

        virtualisation.oci-containers.backend = "podman";
        networking.firewall.allowedTCPPorts = [80 443];
        services.caddy.enable = true;

        imports = [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./configuration.nix
          # ./setup-arr.nix
          disko.nixosModules.default
          impermanence.nixosModules.impermanence
          nixarr.nixosModules.default
          unstableModule
        ];
      };
    };
  };
}

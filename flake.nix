{
  description = "homeserver nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
  };

  outputs = inputs @ {
    nixpkgs,
    impermanence,
    disko,
    ...
  }: {
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
        virtualisation.oci-containers.backend = "podman";
        imports = [
          ./configuration.nix
          disko.nixosModules.default
          impermanence.nixosModules.impermanence
        ];
      };
    };
  };
}

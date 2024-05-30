{
  description = "homeserver nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      };

      # NOTE: yes. it's named like that due to the annoying RGB default settings.
      komorebi = {
        deployment.targetHost = "192.168.88.10";
        deployment.buildOnTarget = true;
        virtualisation.oci-containers.backend = "podman";
        imports = [
          ./configuration.nix
        ];
      };
    };
  };
}

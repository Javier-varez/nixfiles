{
  description = "Workstation NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  outputs = inputs@{ self, nixpkgs, ...}: {
    nixosConfigurations.ws = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}

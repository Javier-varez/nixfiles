{
  description = "My NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-user = {
      url = "git+file:///home/javier/Desktop/nixvim";
    };
  };
  outputs = inputs@{ self, home-manager, nixvim-user, nixpkgs, ...}: {
    nixosConfigurations.ws = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ./host/ws
        ./nixvim.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.javier = import ./home/javier;
        }

      ];
    };

    nixosConfigurations.mininix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ./host/mininix
        ./nixvim.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.javier = import ./home/javier;
        }

      ];
    };
  };
}

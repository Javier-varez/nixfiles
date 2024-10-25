{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-user = {
      url = "git+file:///home/javier/Desktop/flakes/nixvim";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixvim-user, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }

          ({ config, pkgs, ... }:
          {
            environment.systemPackages = [ nixvim-user.packages.${pkgs.system}.default ];
          })
        ];
      };
    };
  };
}

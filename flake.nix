{
  description = "My NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:javier-varez/nixvim-cfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iamb = {
      url = "github:ulyssa/iamb/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      home-manager,
      nixvim,
      nixpkgs,
      nix-darwin,
      nixos-apple-silicon,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      # Additional packages provided by this flake
      packages = forEachSystem (
        system: import ./pkgs { pkgs = inputs.nixpkgs.legacyPackages."${system}"; }
      );

      nixosConfigurations.ws = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/ws
          nixvim.nixosModules.nixvim
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home/javier;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };

      nixosConfigurations.mininix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/mininix
          nixvim.nixosModules.nixvim
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home/javier;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };

      darwinConfigurations.m2 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m2
          nixvim.nixosModules.nixvim
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home/javier;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };

      darwinConfigurations.m1pro = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m1pro
          nixvim.nixosModules.nixvim
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home/javier;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };

      nixosConfigurations.m1pro-asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m1pro-asahi
          nixvim.nixosModules.nixvim
          home-manager.nixosModules.home-manager
          nixos-apple-silicon.nixosModules.apple-silicon-support
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.javier = import ./home/javier;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              enableAsahiWidevine = true;
            };
          }
        ];
      };

    };
}

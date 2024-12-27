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
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
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
          ./home
        ];
      };

      nixosConfigurations.mininix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/mininix
          ./home
        ];
      };

      darwinConfigurations.m2 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m2
          ./home
        ];
      };

      darwinConfigurations.m1pro = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m1pro
          ./home
        ];
      };

      nixosConfigurations.m1pro-asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/m1pro-asahi
          ./home
        ];
      };

      nixosConfigurations.uconsole = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./host/uconsole
          # ./home
          # nixvim.nixosModules.nixvim
        ];
      };

    };
}

{
  description = "My NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:javier-varez/nixvim-cfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    };
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2025-11-18";
    };
    iamb = {
      url = "github:ulyssa/iamb/latest";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pd-mirror = {
      url = "github:javier-varez/pd-mirror";
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

      lib = nixpkgs.lib;
      forEachSystem = lib.genAttrs systems;

      nixosSystems = {
        ws = "x86_64-linux";
        mininix = "x86_64-linux";
        m1pro-asahi = "aarch64-linux";
        m2-asahi = "aarch64-linux";
        vm = "aarch64-linux";
        proxmox = "x86_64-linux";
        thinkpad = "x86_64-linux";
      };

      darwinSystems = {
        m2 = "aarch64-darwin";
        m1pro = "aarch64-darwin";
      };

      generateNixosSystem =
        name: systemOrAttr:
        let
          system = if builtins.isAttrs systemOrAttr then systemOrAttr.system else systemOrAttr;
          enableHome = !(builtins.isAttrs systemOrAttr) || !systemOrAttr.disableHome;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };

          modules = [
            (./host + "/${name}")

          ]
          ++ lib.optional enableHome ./home/nixos.nix;
        };

      generateDarwinSystem =
        name: system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };

          modules = [
            (./host + "/${name}")
            ./home/nix-darwin.nix
          ];
        };

      nixosConfigurations = lib.mapAttrs generateNixosSystem nixosSystems;
      darwinConfigurations = lib.mapAttrs generateDarwinSystem darwinSystems;
    in
    {
      # Additional packages provided by this flake
      packages = forEachSystem (
        system: import ./pkgs { pkgs = inputs.nixpkgs.legacyPackages."${system}"; }
      );

      inherit nixosConfigurations;
      inherit darwinConfigurations;
    };

  nixConfig = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };
}

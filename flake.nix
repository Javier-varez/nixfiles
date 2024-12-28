{
  description = "My NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig-asahi = {
      url = "github:javier-varez/zig-asahi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:javier-varez/nixvim-cfg";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-asahi.follows = "zig-asahi";
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
    u-boot-uconsole = {
      url = "github:javier-varez/u-boot/d1-wip";
      inputs.nixpkgs.follows = "nixpkgs";
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
        vm = "aarch64-linux";
        uconsole = {
          system = "aarch64-linux";
          disableHome = true;
        };
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

          ] ++ lib.optional enableHome ./home/nixos.nix;
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
            ./home/darwin.nix
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
}

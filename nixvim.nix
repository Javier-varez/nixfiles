(
  { inputs, pkgs, ... }:
  {
    environment.systemPackages = [ inputs.nixvim-user.packages.${pkgs.system}.default ];
  }
)

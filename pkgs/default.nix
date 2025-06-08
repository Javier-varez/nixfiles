{ pkgs, ... }:
let
  ltapiserv-rs = pkgs.callPackage ./ltapiserv-rs.nix { };
  sunxi-tools = pkgs.callPackage ./sunxi-tools.nix { };
  widevine = pkgs.callPackage ./widevine.nix { };
  vivado-pkgs = pkgs.callPackage ./vivado.nix { };
in
{
  inherit ltapiserv-rs sunxi-tools widevine;
} // vivado-pkgs

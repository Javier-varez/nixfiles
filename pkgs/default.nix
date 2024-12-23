{ pkgs, ... }:
let
  ltapiserv-rs = pkgs.callPackage ./ltapiserv-rs.nix { };
  sunxi-tools = pkgs.callPackage ./sunxi-tools.nix { };
  widevine = pkgs.callPackage ./widevine.nix { };
  zig-asahi = pkgs.callPackage ./zig-asahi.nix { };
in
{
  inherit ltapiserv-rs sunxi-tools widevine zig-asahi;
}

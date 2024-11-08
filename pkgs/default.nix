{ pkgs, ... }:
let
  ltapiserv-rs = pkgs.callPackage ./ltapiserv-rs.nix { };
in
{
  inherit ltapiserv-rs;
}

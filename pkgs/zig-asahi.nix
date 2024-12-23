{ pkgs, ... }:
pkgs.zig_0_13.overrideAttrs {
  patches = [ ./zig.patch ];
}

{
  pkgs ? import <nixpkgs> { },
  widevine ? import ./widevine.nix { },
}:
pkgs.firefox.overrideAttrs (
  oldAttrs:
  let
    widevineGmpConf = ./gmpwidevine.js;
    cmd =
      oldAttrs.buildCommand
      + ''
        mkdir $out/mytest
        cp ${widevineGmpConf} $out/lib/firefox/defaults/pref/
      '';
  in
  {
    buildCommand = builtins.trace "cmd ${cmd}" cmd;
  }
)

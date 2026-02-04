{
  lib,
  pkgs,
  hasWindowManager,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.isLinux && hasWindowManager) {
    programs.wofi = {
      enable = true;
    };

    home.file.".config/wofi" = {
      enable = true;
      source = ./config;
    };
  };
}

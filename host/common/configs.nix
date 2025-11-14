{ lib, ... }:
{
  options = {
    hasWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    isAsahiLinux = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    allowSuspend = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    desktopConfigurations = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "hyprland"
          "gnome"
        ]
      );
      default = ["gnome" "hyprland"];
    };
  };
}

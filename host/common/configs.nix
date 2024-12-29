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
  };
}

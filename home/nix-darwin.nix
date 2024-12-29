{ config, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.javier = import ./javier;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    isAsahiLinux = false;
    hasWindowManager = true;
  };
}

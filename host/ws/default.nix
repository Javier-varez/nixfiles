{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "ws"; # Define your hostname.

  services.openssh.enable = true;
}

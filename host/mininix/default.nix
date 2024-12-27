{ pkgs, ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "mininix"; # Define your hostname.

  hasWindowManager = true;

  services.openssh.enable = true;
}

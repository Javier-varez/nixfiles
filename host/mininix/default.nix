{ pkgs, ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix
    ../../cluster/node
  ];

  networking.hostName = "mininix"; # Define your hostname.

  hasWindowManager = true;

  services.openssh.enable = true;
}

{ pkgs, ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix
    ../../cluster/node
  ];

  networking.hostName = "mininix"; # Define your hostname.

  hasWindowManager = true;
  allowSuspend = false;

  services.openssh.enable = true;
}

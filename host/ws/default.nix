{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "ws"; # Define your hostname.

  services.openssh.enable = true;
  services.blueman.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  environment.systemPackages = [ inputs.self.packages.${pkgs.system}.vivado ];
}

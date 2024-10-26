{ pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ../common
      ./hardware-configuration.nix
    ];

  networking.hostName = "ws"; # Define your hostname.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.javier = {
    isNormalUser = true;
    description = "Javier Alvarez";
    createHome = true;
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
    ];
    shell = pkgs.fish;
  };

  services.openssh.enable = true;
}

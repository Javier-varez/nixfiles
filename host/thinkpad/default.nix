{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../common
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot";
      }
    ];
  };

  networking.hostName = "thinkpad"; # Define your hostname.
  networking.hostId = "3c8a8180";

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  users.extraGroups = {
    libvirtd.members = [ "javier" ];
    vboxusers.members = [ "javier" ];
    docker.members = [ "javier" ];
  };

  environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.vivado
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.xelab
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.xsim
  ];

  services.fprintd.enable = true;
}

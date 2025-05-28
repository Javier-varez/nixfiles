{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  isAsahiLinux = true;
  hardware.asahi.peripheralFirmwareDirectory = ../../firmware/m2-asahi;

  networking.hostName = "m2-asahi"; # Define your hostname.
  networking.networkmanager = {
    enableStrongSwan = true;
  };

  services.strongswan = {
    enable = true;
  };

  users.users.javier.extraGroups = [
    "libvirtd"
  ];

  environment.systemPackages = with pkgs; [
    inputs.self.packages.${pkgs.system}.widevine
    vagrant
    virt-manager
    spice-gtk
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  # make sure sleep is not disabled
  systemd.sleep.extraConfig = lib.mkForce "";

  system.stateVersion = lib.mkForce "25.05";
}

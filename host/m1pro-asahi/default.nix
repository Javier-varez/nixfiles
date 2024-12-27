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
  hardware.asahi.peripheralFirmwareDirectory = ../../firmware/m1pro-asahi;

  networking.hostName = "m1pro-asahi"; # Define your hostname.

  users.users.javier.extraGroups = [
    "libvirtd"
  ];

  environment.systemPackages = with pkgs; [
    inputs.self.packages.${pkgs.system}.widevine
    (chromium.override {
      widevine-cdm = inputs.self.packages.${pkgs.system}.widevine;
      enableWideVine = true;
    })
    vagrant
    virt-manager
    spice-gtk
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
  };

  # make sure sleep is not disabled
  systemd.sleep.extraConfig = lib.mkForce "";

  system.stateVersion = lib.mkForce "25.05";
}

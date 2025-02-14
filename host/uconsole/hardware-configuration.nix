{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ "dm_mod" "i2c-mv64xxx" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.callPackage ./linux-kernel.nix { };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.buildPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
}

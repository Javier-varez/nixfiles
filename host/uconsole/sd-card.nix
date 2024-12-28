{ inputs, config, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  sdImage = {
    imageName =
      "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-clockworkpi-uconsole.img";

    # Overridden by postBuildCommands
    populateFirmwareCommands = "";

    # Reserve 16 MiB before FW (boot partition) for the u-boot SPL + opensbi + u-boot proper
    firmwarePartitionOffset = 16;
    # Reserve 100 MiB for FW
    firmwareSize = 100;

    postBuildCommands = ''
      # Copy bootloader
      dd conv=notrunc if=${inputs.u-boot-uconsole.packages."${config.nixpkgs.buildPlatform.system}".u-boot}/u-boot-sunxi-with-spl.bin of=$img seek=8 bs=1024
    '';

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}

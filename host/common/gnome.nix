{
  lib,
  config,
  pkgs,
  ...
}:
let
  listContainsElem = list: elem: (lib.lists.findFirst (e: elem == e) null list) != null;
  enableGnome = config.hasWindowManager && (listContainsElem config.desktopConfigurations "gnome");
in
{
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome = {
    enable = enableGnome;
  };

  environment.systemPackages = lib.optional enableGnome pkgs.gnomeExtensions.pop-shell;

  environment.gnome.excludePackages = with pkgs; [
    epiphany # gnome browser
  ];
}

{
  lib,
  config,
  ...
}:
let
  listContainsElem = list: elem: (lib.lists.findFirst (e: elem == e) null list) != null;
  enableHyprland =
    config.hasWindowManager && (listContainsElem config.desktopConfigurations "hyprland");
in
{
  programs = {
    hyprland = {
      enable = enableHyprland;
      withUWSM = true;
      xwayland.enable = enableHyprland;
    };
  };

  services.hypridle = {
    enable = enableHyprland;
  };

  services.upower.enable = enableHyprland;
}

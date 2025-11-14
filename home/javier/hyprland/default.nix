{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  toggleWofi = pkgs.writeShellApplication {
    name = "wofi";
    runtimeInputs = [
      pkgs.wofi
      pkgs.procps
    ];
    text = ''
      if pidof wofi; then
        pkill wofi
      else
        wofi --show drun
      fi
    '';
  };

  wallpaper = pkgs.stdenv.mkDerivation {
    pname = "wallpaper-hyprland";
    version = "1.0.0";
    src = ./wallpaper.png;
    phases = [ "installPhase" ];
    installPhase = ''
      install -D $src $out
    '';
  };

in
{
  imports = [
    ./../wofi
  ];

  home.packages = [
    pkgs.nautilus
    pkgs.dunst
    pkgs.hyprpolkitagent
    pkgs.brightnessctl
    pkgs.hyprpaper
    pkgs.hyprshot

    # Common tools
    # pkgs.feh
  ];

  programs.hyprlock.enable = true;

  home.file = {
    ".config/hypr/hypridle.conf" = {
      enable = true;
      source = ./hypridle.conf;
    };
    ".config/hypr/hyprpaper.conf" = {
      enable = true;
      text = ''
        preload = ${wallpaper}
        wallpaper = , ${wallpaper}
      '';
    };
    ".config/ashell/config.toml" = {
      enable = true;
      source = ./ashell.toml;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # uwsm conflicts with this
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, T, exec, ghostty"
        "$mod, R, exec, ${lib.getExe toggleWofi}"

        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, nautilus"
        "$mod, Z, exec, hyprlock"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo," # dwindle
        "$mod, J, togglesplit," # dwindle
        "$mod, F, fullscreen,"

        ", xf86audioraisevolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"
        ", xf86audiolowervolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1.0"
        ", xf86audiomute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", xf86audiomicmute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", xf86monbrightnessup, exec, brightnessctl set 5%+"
        ", xf86monbrightnessdown, exec, brightnessctl set 5%-"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Screenshot a window
        "$mod, PRINT, exec, hyprshot -m window"
        ", PRINT, exec, hyprshot -m output"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        )
      );

      input = {
        kb_layout = "us";
        repeat_delay = 200;
        repeat_rate = 70;

        touchpad = {
          natural_scroll = true;
        };
      };

      xwayland = {
        enabled = true;
        use_nearest_neighbor = false;
        force_zero_scaling = true;
      };
    };

    extraConfig = ''
      # top-bar
      exec-once = ${inputs.ashell.defaultPackage.${pkgs.system}}/bin/ashell
      exec-once = systemctl --user enable --now dunst.service
      exec-once = systemctl --user enable --now hyprpolkitagent.service
      exec-once = systemctl --user enable --now hyprpaper.service
    '';

    # It is installed as a nixos module already
    package = null;
    portalPackage = null;
  };

  # Indicate to electron apps that they need to use wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}

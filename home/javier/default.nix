{
  config,
  pkgs,
  lib,
  inputs,
  isAsahiLinux,
  hasWindowManager,
  ...
}:
let
  isRiscv64 = pkgs.system == "riscv64-linux";
  isLinux = lib.hasSuffix "-linux" pkgs.system;

  hasIamb = builtins.hasAttr pkgs.system inputs.iamb.packages;
  hasGhostty = hasWindowManager && (builtins.hasAttr pkgs.system inputs.ghostty.packages);
  hasFirefox = hasWindowManager;
  hasNeovim = !isRiscv64;

  iambPackage = lib.optional hasIamb inputs.iamb.packages."${pkgs.system}".default;
  ghosttyPkg = lib.optional hasGhostty (
    inputs.ghostty.packages.${pkgs.system}.default.override { inherit (pkgs) zig_0_13; }
  );

  editor = if hasNeovim then "nvim" else "vim";

  shellAliases = {
    l = "ls";
    ll = "ls -l";
    vi = editor;
    vim = editor;
    gits = "git status";
    cat = "bat";
    k = "kubectl";
  };

  iambConfigPath =
    if pkgs.stdenv.isLinux then
      ".config/iamb/config.toml"
    else
      "Library/Application Support/iamb/config.toml";
  ghosttyConfigPath =
    if pkgs.stdenv.isLinux then
      ".config/ghostty/config"
    else
      "Library/Application Support/com.mitchellh.ghostty/config";

  wallpaper = pkgs.stdenv.mkDerivation {
    pname = "wallpaper";
    version = "1.0.0";
    src = ./wallpaper.jpg;
    phases = ["installPhase"];
    installPhase = ''
      install -D $src $out
    '';
  };

  wallpaper-clear = pkgs.stdenv.mkDerivation {
    pname = "wallpaper-clear";
    version = "1.0.0";
    src = ./wallpaper-clear.jpg;
    phases = ["installPhase"];
    installPhase = ''
      install -D $src $out
    '';
  };
in
{
  home.username = "javier";
  home.homeDirectory = lib.mkForce (
    if pkgs.system == "aarch64-darwin" then "/Users/javier" else "/home/javier"
  );

  home.sessionVariables = {
    EDITOR = editor;
    VISUAL = editor;
  };

  home.packages =
    with pkgs;
    [
      sudo
      vim
      git
      htop
      home-manager
      starship
      gitui
      nerdfonts
      xclip
      rustup
      fastfetch
      onefetch
      ripgrep
      fd
      git-crypt
      gnumake
      gcc
      llvm
      lld
      flex
      bison
    ]
    ++ (lib.optionals (!isRiscv64) [
      # need to make the packages work on riscv64-linux
      nixfmt-rfc-style
      nixd
      python3
      git-repo
      kubectl
      k9s
      glasgow
      zig_0_13
    ])
    ++ (lib.optionals (stdenv.isLinux && !isRiscv64) [
      # Packages only available in linux (except riscv64-linux)
      telegram-desktop
      fractal
      bitwarden-cli
      bitwarden-desktop
      protonvpn-cli
      protonvpn-gui
    ])
    ++ iambPackage
    ++ ghosttyPkg;

  home.file = {
    # iamb configuration file
    "${iambConfigPath}" = {
      enable = hasIamb;
      text = ''
        default_profile = "user"

        [profiles.user]
        user_id = "@javier:allthingsembedded.online"
        url = "https://allthingsembedded.online"

        [settings]
        image_preview = {}
      '';
    };

    # Widevine configuration for asahi linux
    ".mozilla/firefox/${config.programs.firefox.profiles.javier.path}/gmp-widevinecdm" = {
      enable = hasFirefox && isAsahiLinux;
      source = pkgs.runCommandLocal "firefox-widevinecdm" { } ''
        ln -s ${inputs.self.packages.${pkgs.system}.widevine}/gmp-widevinecdm $out
      '';
    };

    # Ghostty configuration
    "${ghosttyConfigPath}" = {
      enable = hasGhostty;
      source = ./ghostty.config;
    };
  };

  home.stateVersion = "24.05";

  programs.fish = {
    enable = true;
    inherit shellAliases;
    interactiveShellInit = ''
      function fish_greeting
        fastfetch
      end
    '';
  };

  programs.nushell = {
    enable = true;
    inherit shellAliases;

    extraEnv = ''
      let fish_completer = {|spans|
        fish --command $'complete "--do-complete=($spans | str join " ")"'
          | from tsv --flexible --noheaders --no-infer
          | rename value description
      }

      $env.config = {
        edit_mode: "vi"
          completions: {
            external: {
              enable: true
              completer: $fish_completer
            }
        }
      }
      $env.EDITOR = "${editor}"
      $env.VISUAL = "${editor}"
    '';
  };

  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Javier Alvarez";
    userEmail = "javier.alvarez@allthingsembedded.net";
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      line_break.disabled = true;
    };
  };

  programs = {
    tmux = {
      enable = true;
      terminal = "xterm-256color";
      extraConfig = ''
        set -g mouse on
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
    };

    firefox = {
      enable = hasFirefox;

      # Firefox should be installed by the system already, we use this only to manage profiles
      package = null;

      profiles.javier = {
        isDefault = true;
      };
    };

  };

  dconf.settings = {
    "org/gnome/desktop/peripherals/keyboard" = with lib.hm.gvariant; {
      repeat-interval = mkUint32 15;
      delay = mkUint32 200;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      show-battery-percentage = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper-clear}";
      picture-uri-dark = "file://${wallpaper}";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FantasqueSansM Nerd Font Mono" ];
    };
  };

  xdg.mimeApps = {
    enable = hasWindowManager && isLinux;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";

      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "application/pdf" = "org.gnome.Evince.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
    };
  };
}

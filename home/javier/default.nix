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
  isX64Linux = pkgs.stdenv.isx86_64 && pkgs.stdenv.isLinux;
  inherit (pkgs.stdenv) isLinux isDarwin;

  hasIamb = builtins.hasAttr pkgs.stdenv.hostPlatform.system inputs.iamb.packages;
  hasGhostty = hasWindowManager && !isDarwin;
  hasFirefox = hasWindowManager;

  iambPackage =
    lib.optional hasIamb
      inputs.iamb.packages."${pkgs.stdenv.hostPlatform.system}".default;
  ghosttyPkg = lib.optional hasGhostty pkgs.ghostty;
  pd-mirror = inputs.pd-mirror.packages.x86_64-linux.default;

  editor = "nvim";

  shellAliases = {
    l = "ls";
    ll = "ls -l";
    vi = editor;
    vim = editor;
    gits = "git status";
    cat = "bat";
    k = "kubectl";
    nvd = lib.getExe inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".nvim-dev;
  };

  iambConfigPath =
    if isLinux then ".config/iamb/config.toml" else "Library/Application Support/iamb/config.toml";
  ghosttyConfigBasePath =
    if isLinux then ".config/ghostty" else "Library/Application Support/com.mitchellh.ghostty";
  ghosttyConfigPath = "${ghosttyConfigBasePath}/config";
  ghosttyDarwinConfigPath = "${ghosttyConfigBasePath}/darwin";
  ghosttyLinuxConfigPath = "${ghosttyConfigBasePath}/linux";
  jujutsuConfigPath = ".config/jj/config.toml";

  wallpaper = pkgs.stdenv.mkDerivation {
    pname = "wallpaper";
    version = "1.0.0";
    src = ./wallpaper.jpg;
    phases = [ "installPhase" ];
    installPhase = ''
      install -D $src $out
    '';
  };

  wallpaper-clear = pkgs.stdenv.mkDerivation {
    pname = "wallpaper-clear";
    version = "1.0.0";
    src = ./wallpaper-clear.jpg;
    phases = [ "installPhase" ];
    installPhase = ''
      install -D $src $out
    '';
  };
in
rec {
  imports = [ ./hyprland ];

  home.username = "javier";
  home.homeDirectory = if isDarwin then "/Users/javier" else "/home/javier";

  home.sessionVariables = {
    EDITOR = editor;
    VISUAL = editor;
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.claude/local"
  ]
  ++ (lib.optionals isDarwin [ "/opt/homebrew/bin" ]);

  home.packages =
    with pkgs;
    [
      asciinema
      bison
      cmake
      delta
      fastfetch
      fd
      flex
      git
      git-crypt
      git-lfs
      gitui
      gnumake
      go
      home-manager
      htop
      jujutsu
      lld
      llvm
      clang
      ninja
      nodejs_24
      onefetch
      ripgrep
      rustup
      starship
      vim
      xclip
      jq
      git-repo
      k9s
      kubectl
      nixd
      nixfmt
      python3
      zig
      mold
      yazi
      s5cmd
    ]
    ++ (lib.optionals isLinux [
      bluespec
      kicad
      sudo
      pciutils
      bitwarden-cli
      bitwarden-desktop
      fractal
      protonvpn-gui
      telegram-desktop
      pd-mirror
      glasgow
    ])
    ++ (lib.optional isX64Linux saleae-logic-2)
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
        ln -s ${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.widevine}/gmp-widevinecdm $out
      '';
    };

    # Ghostty configuration
    "${ghosttyConfigPath}" = {
      # in darwin we can't install ghostty automatically, but we can add the configuration
      enable = hasGhostty || isDarwin;
      source = ./ghostty.config;
    };

    "${ghosttyDarwinConfigPath}" = {
      enable = isDarwin;
      source = ./ghostty_darwin.config;
    };

    "${ghosttyLinuxConfigPath}" = {
      enable = hasGhostty && isLinux;
      source = ./ghostty_linux.config;
    };

    ".config/aerospace" = {
      enable = isDarwin;
      source = ./aerospace;
    };

    ".config/sketchybar" = {
      enable = isDarwin;
      source = ./sketchybar;
    };

    # Jujutsu config
    "${jujutsuConfigPath}" = {
      enable = true;
      source = ./jujutsu.toml;
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

      if test -e $HOME/.config/fish/custom_config.fish
          source $HOME/.config/fish/custom_config.fish
      end
    '';
  };

  programs.bat = {
    enable = true;
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Javier Alvarez";
      user.email = "javier.alvarez@allthingsembedded.net";
    };
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
      enable = hasFirefox && isAsahiLinux;

      # Firefox should be installed by the system already, we use this only to manage profiles
      package = null;

      profiles.javier = {
        isDefault = true;
      };
    };

  };

  dconf.settings = lib.mkIf hasWindowManager {
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

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FantasqueSansM Nerd Font Mono" ];
      };
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

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
  isX64Linux = pkgs.system == "x86_64-linux";
  inherit (pkgs.stdenv) isLinux isDarwin;

  hasIamb = builtins.hasAttr pkgs.system inputs.iamb.packages;
  hasGhostty =
    hasWindowManager && !isDarwin && (builtins.hasAttr pkgs.system inputs.ghostty.packages);
  hasFirefox = hasWindowManager;
  hasNeovim = !isRiscv64;

  iambPackage = lib.optional hasIamb inputs.iamb.packages."${pkgs.system}".default;
  ghosttyPkg = lib.optional hasGhostty (inputs.ghostty.packages.${pkgs.system}.default);

  editor = if hasNeovim then "nvim" else "vim";

  shellAliases = {
    l = "ls";
    ll = "ls -l";
    vi = editor;
    vim = editor;
    gits = "git status";
    cat = "bat";
    k = "kubectl";
    nvd = lib.getExe inputs.nixvim.packages."${pkgs.system}".nvim-dev;
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
  ] ++ (lib.optionals isDarwin [ "/opt/homebrew/bin" ]);

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
      ninja
      nodejs_24
      onefetch
      ripgrep
      rustup
      starship
      vim
      xclip
    ]
    ++ (lib.optionals (!isRiscv64) [
      # need to make the packages work on riscv64-linux
      git-repo
      glasgow
      k9s
      kubectl
      nixd
      nixfmt-rfc-style
      python3
      zig_0_14
    ])
    ++ (lib.optionals isLinux [
      bluespec
      kicad
      sudo
    ])
    ++ (lib.optionals (isLinux && !isRiscv64) [
      # Packages only available in linux (except riscv64-linux)
      bitwarden-cli
      bitwarden-desktop
      fractal
      protonvpn-cli
      protonvpn-gui
      telegram-desktop
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
        ln -s ${inputs.self.packages.${pkgs.system}.widevine}/gmp-widevinecdm $out
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
        edit_mode: "emacs"

        completions: {
          external: {
            enable: true
            completer: $fish_completer
          }
        }

        hooks: {
          pre_prompt: [{ ||
            if (which direnv | is-empty) {
              return
            }

            direnv export json | from json | default {} | load-env
            if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
              $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
            }
          }]
        }
      }

      $env.EDITOR = "${editor}"
      $env.VISUAL = "${editor}"
      $env.PATH = ($env.PATH | split row (char esep) | append "${toString home.homeDirectory}/go/bin")
      $env.PATH = ($env.PATH | split row (char esep) | append "${toString home.homeDirectory}/.cargo/bin")
      $env.PATH = ($env.PATH | split row (char esep) | append "${toString home.homeDirectory}/.claude/local")
    '';
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
      enable = hasFirefox && isAsahiLinux;

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

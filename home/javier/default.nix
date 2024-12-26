{
  config,
  pkgs,
  lib,
  inputs,
  enableAsahiWidevine ? false,
  ...
}:
let
  shellAliases = {
    l = "ls";
    ll = "ls -l";
    vi = "nvim";
    vim = "nvim";
    gits = "git status";
    cat = "bat";
    k = "kubectl";
  };

  iambConfigPath =
    if pkgs.stdenv.isLinux then
      ".config/iamb/config.toml"
    else
      "Library/Application Support/iamb/config.toml";

  fixed-zig =
    if pkgs.system == "aarch64-linux" then
      inputs.self.packages."${pkgs.system}".zig-asahi
    else
      pkgs.zig;
in
{
  home.username = "javier";
  home.homeDirectory = if pkgs.system == "aarch64-darwin" then "/Users/javier" else "/home/javier";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages =
    with pkgs;
    [
      git
      htop
      home-manager
      starship
      fish
      gitui
      nerdfonts
      alacritty
      xclip
      rustup
      tmux
      fastfetch
      onefetch
      nixfmt-rfc-style
      nixd
      ripgrep
      fd
      nushell
      python3
      kubectl
      k9s
      git-crypt
      git-repo
      gnumake
      gcc14
      llvm_19
      lld_19
      flex
      bison
      inputs.iamb.packages."${pkgs.system}".default
      glasgow
      fixed-zig
    ]
    ++ lib.optionals stdenv.isLinux [
      # Packages only available in linux
      telegram-desktop
      fractal
      bitwarden-cli
      bitwarden-desktop
      protonvpn-cli
      protonvpn-gui
    ]
    ++ (with python3Packages; [
      matplotlib
      numpy
      pandas
      black
    ]);

  home.file = {
    "${iambConfigPath}" = {
      enable = true;
      text = ''
        default_profile = "user"

        [profiles.user]
        user_id = "@javier:allthingsembedded.online"
        url = "https://allthingsembedded.online"

        [settings]
        image_preview = {}
      '';
    };
    ".mozilla/firefox/${config.programs.firefox.profiles.javier.path}/gmp-widevinecdm" = {
      enable = enableAsahiWidevine;
      source = pkgs.runCommandLocal "firefox-widevinecdm" { } ''
        ln -s ${inputs.self.packages.${pkgs.system}.widevine}/gmp-widevinecdm $out
      '';
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
      $env.config = {
        edit_mode: "vi"
      }
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

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        # decorations = "None";
        opacity = 0.9;
        padding = {
          x = 10;
          y = 10;
        };
      };
      font = {
        normal = {
          family = "FantasqueSansM Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "FantasqueSansM Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "FantasqueSansM Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "FantasqueSansM Nerd Font Mono";
          style = "Bold Italic";
        };
        size = 12;
      };
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
      enable = true;

      # Firefox should be installed by the system already, we use this only to manage profiles
      package = null;

      profiles.javier = {
        isDefault = true;
      };
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FantasqueSansM Nerd Font Mono" ];
    };
  };
}

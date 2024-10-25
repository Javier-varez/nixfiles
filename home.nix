{ config, pkgs, ... }:
{
  home.username = "javier";
  home.homeDirectory = "/home/javier";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
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
    neofetch
    nixfmt-rfc-style
    nixd
  ];

  home.stateVersion = "24.05";

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "ls";
      ll = "ls -l";
      vi = "nvim";
      vim = "nvim";
      gits = "git status";
    };
    interactiveShellInit = ''
      function fish_greeting
        neofetch
      end
    '';
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
        padding = { x = 10; y = 10; };
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

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {}
    '';
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    extraConfig = ''
      set -g mouse on
      set-option -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FantasqueSansM Nerd Font Mono" ];
    };
  };
}

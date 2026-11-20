{ inputs, pkgs, ... }:
{
  imports = [
  ];

  environment.systemPackages = [
    pkgs.vim
    inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".nvim
  ];

  home-manager.users.javier = { config, ... }: {
    home.sessionVariables.SSH_AUTH_SOCK =
      "${config.home.homeDirectory}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
  };

  nix.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  programs = {
    # Enable alternative shell support in nix-darwin.
    fish.enable = true;

    direnv = {
      enable = true;
    };
  };

  users.users.javier = {
    description = "Javier Alvarez";
    home = "/Users/javier";
    shell = pkgs.fish;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

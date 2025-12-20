{ inputs, pkgs, ... }:
{
  imports = [
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.iterm2
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ltapiserv-rs
    inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".nvim
  ];

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

  launchd.agents.ltapiserv-rs = {
    command = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ltapiserv-rs}/bin/ltapiserv-rs";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

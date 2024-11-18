{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  options = {
    hasWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = lib.mkDefault "Europe/Zurich";

    i18n.defaultLocale = "en_US.UTF-8";

    # Enable the X11 windowing system.
    services.xserver.enable = if config.hasWindowManager then true else false;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = if config.hasWindowManager then true else false;
    services.xserver.desktopManager.gnome = {
      enable = if config.hasWindowManager then true else false;
      extraGSettingsOverrides = ''
        # change key repeat rate
        [org.gnome.desktop.peripherals.keyboard]
        repeat-interval=15
        delay=200

        [org.gnome.desktop.interface]
        color-scheme="prefer-dark"
      '';
    };

    # Configure keymap in X11
    services.xserver.xkb.layout = "us";

    services.printing.enable = true;

    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    # services.pipewire = {
    #   enable = true;
    #   pulse.enable = true;
    # };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      man-pages
      man-pages-posix
      git
      fish
      gnomeExtensions.pop-shell
    ];

    programs = {
      firefox = {
        enable = true;
        languagePacks = [
          "en-US"
          "es-ES"
        ];

        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DontCheckDefaultBrowser = true;

          ExtensionSettings = {
            "*".installation_mode = "blocked";
            # Vimium
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/%7Bd7742d87-e61d-4b78-b8a1-b469842139fa%7D/latest.xpi";
            };
            # Dark reader
            "addon@darkreader.org" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/addon@darkreader.org/latest.xpi";
            };
          };
        };
      };
      fish.enable = true;
    };

    # Enables udev rules for glasgow interface explorer
    hardware.glasgow.enable = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    nixpkgs.config.allowUnfree = true;

    documentation.dev.enable = true;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
    # to actually do that.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}

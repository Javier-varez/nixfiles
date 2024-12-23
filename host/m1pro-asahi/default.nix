# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.asahi.enable = true;
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.peripheralFirmwareDirectory = ../../firmware/m1pro-asahi;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "m1pro-asahi"; # Define your hostname.
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      # change key repeat rate
      [org.gnome.desktop.peripherals.keyboard]
      repeat-interval=15
      delay=200

      [org.gnome.desktop.interface]
      color-scheme="prefer-dark"
    '';
  };

  users.users.javier = {
    isNormalUser = true;
    description = "Javier Alvarez";
    createHome = true;
    extraGroups = [
      "wheel"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    git
    fish
    gnomeExtensions.pop-shell
    usbutils
    inputs.self.packages.${pkgs.system}.sunxi-tools
    inputs.self.packages.${pkgs.system}.widevine
    (chromium.override {
      widevine-cdm = inputs.self.packages.${pkgs.system}.widevine;
      enableWideVine = true;
    })
  ];

  programs = {
    firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "es-ES"
      ];

      autoConfig = ''
        pref("media.gmp-widevinecdm.version", "system-installed");
        pref("media.gmp-widevinecdm.visible", true);
        pref("media.gmp-widevinecdm.enabled", true);
        pref("media.gmp-widevinecdm.autoupdate", false);
        pref("media.eme.enabled", true);
        pref("media.eme.encrypted-media-encryption-scheme.enabled", true);
      '';

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
          # User-Agent Switcher and Manager
          "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/%7Ba6c4a591-f1b2-4f03-b3ff-767e5bedf4e7%7D/latest.xpi";
          };
        };
      };
    };

    fish.enable = true;

    # Add support for showing unknown commands in the shell
    command-not-found.enable = false;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # Enables udev rules for glasgow interface explorer
  hardware.glasgow.enable = true;

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "70-allwinner-fex.rules";
      text = ''
        # FEL access to allwinner devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", MODE="660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-allwinner-fex.rules";
    })
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  documentation.dev.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}

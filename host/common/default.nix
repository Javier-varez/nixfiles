{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  nixvim = inputs.nixvim.packages."${pkgs.stdenv.hostPlatform.system}".nvim;
in
{
  imports = [ ./configs.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = !config.isAsahiLinux;

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-strongswan
      networkmanager-l2tp
    ];
  };
  networking.wireless.iwd = {
    enable = config.isAsahiLinux;
    settings.General.EnableNetworkConfiguration = true;
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  # Make it possible to resolve multicast dns
  services.resolved.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = config.hasWindowManager;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = config.hasWindowManager;
  services.desktopManager.gnome = {
    enable = config.hasWindowManager;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  services.printing.enable = true;

  users.users.javier = {
    isNormalUser = true;
    description = "Javier Alvarez";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "dialout"
      "docker"
    ];
    packages = with pkgs; [ firefox ];
    shell = pkgs.nushell;
    initialHashedPassword = "$6$GdR/WV.SP7Eqhljw$rrH5ptrinOOYNLBf13EUIsqEXqcW25.ryZ/7CvqcbMBeeBn8d1jmQWYQD.LoT3kRY.DGLyfI8mw5k1ne/ohG//";
  };

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  fonts.packages = (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      sudo
      man-pages
      man-pages-posix
      file
      git
      fish
      usbutils
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.sunxi-tools
      nixvim
      bpftrace
      openvpn
    ]
    ++ (lib.optional config.hasWindowManager gnomeExtensions.pop-shell);

  environment.gnome.excludePackages = with pkgs; [
    epiphany # gnome browser
  ];

  programs = {
    firefox = {
      enable = config.hasWindowManager;

      package = pkgs.firefox;

      languagePacks = [
        "en-US"
        "es-ES"
      ];

      autoConfig = lib.optionalString config.isAsahiLinux ''
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
        }
        // lib.optionalAttrs config.isAsahiLinux {
          # User-Agent Switcher and Manager
          "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/%7Ba6c4a591-f1b2-4f03-b3ff-767e5bedf4e7%7D/latest.xpi";
          };
        };

        Preferences = {
          "extensions.pocket.enabled" = {
            Status = "locked";
            Value = false;
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

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };
  };

  services.hypridle = {
    enable = true;
  };

  home-manager.backupFileExtension = "hm-backup";
  # services.displayManager.ly.enable = config.hasWindowManager;
  services.displayManager.sddm = {
    enable = config.hasWindowManager;
    wayland.enable = config.hasWindowManager;
  };
  services.upower.enable = true;

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "70-allwinner-fex.rules";
      text = ''
        # FEL access to allwinner devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", MODE="660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-allwinner-fex.rules";
    })

    (pkgs.writeTextFile {
      name = "70-digilent.rules";
      text = ''
        ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Digilent", MODE:="666"
      '';
      destination = "/etc/udev/rules.d/70-digilent.rules";
    })
    (pkgs.writeTextFile {
      name = "70-stlink.rules";
      text = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-stlink.rules";
    })
    (pkgs.writeTextFile {
      name = "70-saleae.rules";
      text = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1005", MODE="660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-saleae.rules";
    })
  ];

  systemd.sleep.extraConfig = lib.mkIf (!config.allowSuspend) ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "@wheel" ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nixpkgs.config.allowUnfree = true;

  documentation.dev.enable = true;

  hardware = {
    # Enables udev rules for glasgow interface explorer
    glasgow.enable = true;
  }
  // (lib.optionalAttrs config.isAsahiLinux {
    asahi = {
      enable = true;
      # Set hardware.asahi.peripheralFirmwareDirectory in your custom config
    };
  });

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };

  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

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
}

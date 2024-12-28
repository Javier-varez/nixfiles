{
  lib,
  pkgs,
  ...
}:
let
  javier-pwd = (
    pkgs.stdenv.mkDerivation {
      pname = "javier-passwd";
      version = "1.0";
      src = ./javier-pwd.secret;
      phases = [ "installPhase" ];
      installPhase = ''
        install -D --mode 0440 $src $out
      '';
    }
  );
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sd-card.nix
  ];

  boot = {
    loader = {
      # Use an extlinux bootloader (external)
      generic-extlinux-compatible.enable = true;
      grub.enable = lib.mkForce false;
    };

    kernelParams = [
      "console=ttyS1,115200n8"
      "console=ttyGS0,115200"
      "earlycon=sbi"

      # Enable for debugging initrd issues
      # "boot.shell_on_fail"
    ];

    # Enable for debugging kernel boot
    # consoleLogLevel = 7;
  };

  hardware.deviceTree = {
    enable = true;
    name = "allwinner/sun20i-d1-uconsole-v3.14.dtb";
  };

  networking.hostName = "uconsole"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  # Do not enable the X11 windowing system.
  services.xserver.enable = false;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  users.users.javier = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    hashedPasswordFile = "${javier-pwd}";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  networking = {
    firewall.enable = false;

    interfaces = {
      "usb0" = {
        ipv4.addresses = [
          {
            address = "10.0.0.1";
            prefixLength = 24;
          }
        ];
      };
    };

    # Connect via 10.0.0.2 to host
    defaultGateway = "10.0.0.2";

    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}

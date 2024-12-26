{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.linuxPackages_custom {
  version = "6.11";

  src = pkgs.fetchFromGitHub {
    owner = "javier-varez";
    repo = "uconsole-linux";
    rev = "19bb05f06253d5dd0a49cf28d6dfedd4e54db1f4";
    sha256 = "sha256-g9WgKf+gaUYV8RUZ7aEpxf+3HMGo1ElfQNrkZKiLJgQ=";
  };

  configfile = ./uconsole_defconfig;
}

{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "sunxi-tools";
  buildInputs = with pkgs; [
    pkg-config
    libusb1.dev
    libz.dev
    dtc
  ];

  src = pkgs.fetchFromGitHub {
    owner = "linux-sunxi";
    repo = "sunxi-tools";
    rev = "29d48c3c39d74200fb35b5750f99d06a4886bf2e";
    sha256 = "sha256-IUgAM/wVHGbidJ2bfLcTIdXg7wxEjxCg1IA8FtDFpR4=";
  };

  installPhase = ''
    make install DESTDIR=$out PREFIX=
  '';
}

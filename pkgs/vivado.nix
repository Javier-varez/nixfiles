{
  stdenv,
  lib,
  bash,
  coreutils,
  writeScript,
  requireFile,
  patchelf,
  procps,
  makeWrapper,
  ncurses,
  zlib,
  libX11,
  libXrender,
  libxcb,
  libXext,
  libXtst,
  libXi,
  libxcrypt,
  glib,
  freetype,
  gtk2,
  buildFHSEnv,
  gcc,
  ncurses5,
  glibc,
  gperftools,
  fontconfig,
  liberation_ttf,
}:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2024.2-extracted";

    src = requireFile rec {
      name = "FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001.tar";
      url = "https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001.tar";
      sha256 = "974f92f749bd15e38c45d8707c45b39ef903819310dc196bcaafb66eb16c8f3c";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (124.81GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf ];

    builder = writeScript "${name}-builder" ''
      #! ${bash}/bin/bash
      source $stdenv/setup

      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre21.0.1_12/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2024.2";

    nativeBuildInputs = [ zlib ];
    buildInputs = [
      patchelf
      procps
      ncurses
      makeWrapper
    ];

    extracted = "${extractedSource}";

    builder = ./vivado-builder-2024_2.sh;
    inherit ncurses;

    libPath = lib.makeLibraryPath [
      stdenv.cc.cc
      ncurses
      zlib
      libX11
      libXrender
      libxcb
      libXext
      libXtst
      libXi
      freetype
      gtk2
      glib
      libxcrypt
      gperftools
      glibc.dev
      fontconfig
      liberation_ttf
    ];

    meta = {
      description = "Xilinx Vivado WebPack Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
    };
  };

in
{
  vivado = buildFHSEnv {
    name = "vivado";
    targetPkgs = _pkgs: [
      vivadoPackage
    ];
    multiPkgs =
      pkgs: with pkgs; [
        coreutils
        gcc
        ncurses5
        zlib
        glibc.dev
        libxcrypt-legacy
      ];
    runScript = "vivado";
  };

  xelab = buildFHSEnv {
    name = "xelab";
    targetPkgs = _pkgs: [
      vivadoPackage
    ];
    multiPkgs =
      pkgs: with pkgs; [
        coreutils
        gcc
        ncurses5
        zlib
        glibc.dev
        libxcrypt-legacy
      ];
    runScript = "xelab";
  };
}

{
  pkgs ? import <nixpkgs> {},
}:
let
  inherit (pkgs) lib stdenv;
  chromeWidevinePath = "share/google/chrome/WidevineCdm";
  firefoxWidevinePath = "gmp-widevinecdm/system-installed";
in
stdenv.mkDerivation (finalAttrs: {
  name = "widevine-cdm";
  pname = "widevine-cdm";
  lacrosVersion = "120.0.6098.0";

  widevineInstaller = pkgs.fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "widevine-installer";
    rev = "7a3928fe1342fb07d96f61c2b094e3287588958b";
    sha256 = "sha256-XI1y4pVNpXS+jqFs0KyVMrxcULOJ5rADsgvwfLF6e0Y=";
  };

  src = pkgs.fetchurl {
    url = "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-${finalAttrs.lacrosVersion}";
    hash = "sha256-OKV8w5da9oZ1oSGbADVPCIkP9Y0MVLaQ3PXS3ZBLFXY=";
  };

  nativeBuildInputs = [
    pkgs.squashfsTools
    pkgs.python3
  ];

  unpackPhase = ''
    unsquashfs -q $src 'WidevineCdm/*'
    mkdir -p $out/${chromeWidevinePath}
    python3 $widevineInstaller/widevine_fixup.py squashfs-root/WidevineCdm/_platform_specific/cros_arm64/libwidevinecdm.so $out/${chromeWidevinePath}/libwidevinecdm.so

    cp squashfs-root/WidevineCdm/manifest.json $out/${chromeWidevinePath}/
    cp squashfs-root/WidevineCdm/LICENSE $out/${chromeWidevinePath}/LICENSE.txt

    mkdir -p $out/${chromeWidevinePath}/_platform_specific/linux_arm64
    cp $out/${chromeWidevinePath}/libwidevinecdm.so $out/${chromeWidevinePath}/_platform_specific/linux_arm64/
    mkdir -p $out/${chromeWidevinePath}/_platform_specific/linux_arm64

    mkdir -p $out/${firefoxWidevinePath}/
    cp squashfs-root/WidevineCdm/manifest.json $out/${firefoxWidevinePath}/
    cp $out/${chromeWidevinePath}/libwidevinecdm.so $out/${firefoxWidevinePath}/
  '';

  # Accoring to widevine-installer: "Hack because Chromium hardcodes a check for this right now..."
  postInstall = ''
    mkdir -p "$out/${chromeWidevinePath}/_platform_specific/linux_x64"
    touch "$out/${chromeWidevinePath}/_platform_specific/linux_x64/libwidevinecdm.so"
  '';

  meta = {
    description = "Widevine CDM";
    homepage = "https://www.widevine.com";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})

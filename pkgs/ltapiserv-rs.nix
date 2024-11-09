{
  lib,
  fetchFromGitHub,
  fetchurl,
  pkgs,
  rustPlatform,
}:
let
  frequencyDictionary = fetchurl {
    url = "https://raw.githubusercontent.com/reneklacan/symspell/17466ca2c2ce00bc1f526f38f6f3b4c7f23a6a4e/data/frequency_dictionary_en_82_765.txt";
    hash = "sha256-QyI6qDtVUZhR1ck7r5b3hD5fVBDyYjqc4mNAmrUDFLI=";
  };

  enTokenizer = fetchurl {
    url = "https://github.com/bminixhofer/nlprule/releases/download/0.6.4/en_tokenizer.bin.gz";
    hash = "sha256-tQDdIIrOm6IY9rUvjNq2PUwJ1vKWfpvY+Re/WYTURoo=";
  };

  enRules = fetchurl {
    url = "https://github.com/bminixhofer/nlprule/releases/download/0.6.4/en_rules.bin.gz";
    hash = "sha256-NbveZkJk8GYK3LDY85Vc3vI1n1AvCqJuikaPQ5c81yw=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "ltapiserv-rs";
  version = "v0.2.3";

  nativeBuildInputs = with pkgs; [
    gzip
  ];

  buildInputs =
    with pkgs;
    lib.optionals stdenv.isDarwin [
      # Additional darwin specific inputs can be set here
      # libiconv
      darwin.apple_sdk.frameworks.SystemConfiguration
      darwin.apple_sdk.frameworks.CoreServices
    ];

  src = fetchFromGitHub {
    owner = "cpg314";
    repo = pname;
    rev = version;
    hash = "sha256-O9e8BrGpYSweapRc6FYdOudfvlMv3hkndIb55r0rYZw=";
  };

  checkFlags = [
    # This test is impure because it attempts to write to FS path.
    "--skip=main"
  ];

  preBuild = ''
    mkdir en_US
    cat  ${enTokenizer} | ${pkgs.gzip}/bin/gunzip -c > en_US/tokenizer.bin
    cat ${enRules} | ${pkgs.gzip}/bin/gunzip -c > en_US/rules.bin
    cp ${frequencyDictionary} en_US/frequency_dict.txt
    tar czf en_US.tar.gz en_US/*
    tar tvf en_US.tar.gz
  '';

  cargoHash = "sha256-W0sU9mY9nVrth/SBiQFhv7nJjDFQYrQB/470Jv7ln4s=";

  meta = {
    description = "Server implementation of the LanguageTool API for offline grammar and spell checking, based on nlprule and symspell. And a small graphical command-line client.";
    homepage = "https://github.com/cpg314/ltapiserv-rs";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}

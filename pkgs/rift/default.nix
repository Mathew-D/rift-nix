{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "rift";
  version = "5.24.4";

  src = pkgs.fetchurl {
    url = "https://riftforeve.online/download/rift-5.24.4-linux-amd64.tar.gz";
    hash = "sha256-Qsymo/z3tP8g0g8A5xfZPvv1aVvXiVeUvcjGDb/N054=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  dontUnpack = false;

  installPhase = ''
    mkdir -p $out/opt/rift
    cp -r ./* $out/opt/rift

    # find actual binary inside extracted folder
    BIN=$(find $out/opt/rift -type f -name rift -executable | head -n 1)

    mkdir -p $out/bin
    makeWrapper $BIN $out/bin/rift
  '';
}

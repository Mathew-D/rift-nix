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

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/opt/rift
    cp -r ./* $out/opt/rift

    mkdir -p $out/bin
    makeWrapper $out/opt/rift/rift $out/bin/rift
  '';
}

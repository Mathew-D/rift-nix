{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "rift";
  version = "5.24.3";

  src = pkgs.fetchurl {
    url = "https://riftforeve.online/download/debian/rift_5.24.3_amd64.deb";
    hash = "sha256-EG2eUuLgcNF7j/48zmYaUuEG3hEmGuZ8vB3mXPTFbnk=";
  };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    alsa-lib
    freetype
    gcc-unwrapped
    glibc
    libx11
    libxext
    libxi
    libxrender
    libxtst
    zlib

   wayland
  wayland-protocols

  libxkbcommon
  libGL

  libX11
  libXext
  libXi
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
    mkdir -p $out/bin
    ln -sf $out/usr/bin/rift $out/bin/rift
  '';
}

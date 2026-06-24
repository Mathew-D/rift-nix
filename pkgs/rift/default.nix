{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "rift";
  version = "5.24.3";

  src = pkgs.fetchurl {
    url = "https://riftforeve.online/download/debian/rift_${version}_amd64.deb";
    hash = "sha256-EG2eUuLgcNF7j/48zmYaUuEG3hEmGuZ8vB3mXPTFbnk=";
  };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    freetype
    zlib

    libGL
    libxkbcommon
    wayland
    wayland-protocols

    libX11
    libXext
    libXi
    libXrender
    libXtst
    libXrandr
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/

    # Fix broken absolute symlink from the Debian package:
    # /usr/bin/rift -> /usr/lib/nohus/rift/bin/rift
    rm -f $out/bin/rift
    ln -s ../lib/nohus/rift/bin/rift $out/bin/rift
  '';

  postFixup = ''
    wrapProgram $out/bin/rift \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.alsa-lib
          pkgs.libGL
          pkgs.libxkbcommon
          pkgs.wayland

          pkgs.libX11
          pkgs.libXext
          pkgs.libXi
          pkgs.libXrender
          pkgs.libXtst
          pkgs.libXrandr
        ]
      }
  '';

  meta = with pkgs.lib; {
    description = "RIFT";
    platforms = platforms.linux;
  };
}

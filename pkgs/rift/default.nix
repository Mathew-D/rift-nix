{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "rift";
  version = "5.29.0";

  src = pkgs.fetchurl {
    url = "https://riftforeve.online/download/debian/rift_${version}_amd64.deb";
    hash = "sha256-fpB8sICdEmWSde4xGbBV6I4ZfQfExskWO3ziWAwLEFk=";
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
fontconfig
freetype
libuuid
expat
    libGL
    libxkbcommon
    wayland
    wayland-protocols
    
libgcc
    stdenv.cc.cc.lib
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libXrandr
libXft
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

    # Desktop files from the Debian package point to /usr paths that do not
    # exist in Nix; rewrite them to use the packaged launcher.
    if [ -d "$out/share/applications" ]; then
      substituteInPlace $out/share/applications/*.desktop \
        --replace-fail 'Exec=/usr/lib/nohus/rift/bin/rift' "Exec=$out/bin/rift"

      # Some launchers still show this helper entry despite NoDisplay=true.
      rm -f "$out/share/applications/dev.nohus.rift.window.desktop"
    fi
  '';

  postFixup = ''
    wrapProgram $out/bin/rift \
 --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.xwininfo
        pkgs.xprop
        pkgs.wmctrl
      ]
    } \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.alsa-lib
          pkgs.libGL
          pkgs.dbus
 pkgs.fontconfig
        pkgs.freetype
        pkgs.libXft
          pkgs.gtk3
          pkgs.glib
          pkgs.gdk-pixbuf
          pkgs.libxkbcommon
          pkgs.libXft
          pkgs.wayland
          pkgs.stdenv.cc.cc.lib
          pkgs.libgcc
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

# /etc/nixos/pkgs/discord-music-presence.nix  
{ pkgs, lib }:  
  
let  
  version = "2.3.5";  
in  
pkgs.stdenv.mkDerivation {  
  pname = "discord-music-presence";  
  inherit version;  
  
  src = pkgs.fetchurl {  
    url = "https://github.com/ungive/discord-music-presence/releases/download/v${version}/musicpresence-${version}-linux-x86_64.tar.gz";  
    sha256 = "sha256-BDgM1SfyEXC0oW+J33mYKwqRrvZX3cy/X9k7Yuk4kS8=";  
  };  
  
  nativeBuildInputs = [  
    pkgs.autoPatchelfHook  
  ];  
  
  buildInputs = with pkgs; [  
    stdenv.cc.cc.lib  
    glib  
    gtk3  
  
    xorg.libX11  
    xorg.libXrandr  
    xorg.libXrender  
    xorg.libXcursor  
    xorg.libXi  
    xorg.libXext  
    xorg.libXfixes  
    xorg.libXdamage  
    xorg.libXcomposite  
    xorg.libxcb  
    libxkbcommon  
    xorg.xkeyboardconfig  # for XKB_CONFIG_ROOT  
  
    alsa-lib  
    libpulseaudio  
    dbus  
  
    e2fsprogs      # libcom_err.so.2  
    libgpg-error   # libgpg-error.so.0  
  ];  
  
  dontConfigure = true;  
  dontBuild     = true;  
  
  installPhase = ''  
    set -e  
    runHook preInstall  
  
    mkdir -p "$out"  
    cp -r usr/* "$out/"  
  
    if [ ! -x "$out/bin/musicpresence" ]; then  
      echo "ERROR: expected $out/bin/musicpresence to exist and be executable" >&2  
      ls -R  
      exit 1  
    fi  
  
    # Move the real binary somewhere *outside* bin but still inside the package  
    mkdir -p "$out/libexec"  
    mv "$out/bin/musicpresence" "$out/libexec/musicpresence.real"  
  
    # Only install the wrapper into bin (this is what ends up on PATH)  
    cat > "$out/bin/discord-music-presence" <<EOF  
#!${pkgs.bash}/bin/bash  
export XKB_CONFIG_ROOT="${pkgs.xorg.xkeyboardconfig}/share/X11/xkb"  
exec "$out/libexec/musicpresence.real" "\$@"  
EOF  
  
    chmod 0755 "$out/bin/discord-music-presence"  
  
    runHook postInstall  
  ''; 

  postFixup = ''  
    chmod 0755 "$out/bin/discord-music-presence" || true  
  '';   
  
  meta = with lib; {  
    description = "Discord music status that works with any media player";  
    homepage    = "https://github.com/ungive/discord-music-presence";  
    license     = licenses.mit;  
    platforms   = platforms.linux;  
  };  
}  

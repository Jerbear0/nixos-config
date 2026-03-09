{ config, lib, pkgs, ... }:
with lib;
let
  alcom-pkg = pkgs.stdenv.mkDerivation {
    pname = "alcom";
    version = "1.1.5";
    src = pkgs.fetchurl {
      url = "https://github.com/vrc-get/vrc-get/releases/download/gui-v1.1.5/alcom_1.1.5_amd64.deb";
      hash = "sha256-dL+mC7bHDu4qPpTCpIepNT6F1gZTtXrw+cR5UVgPIKM=";
    };
    nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook ];
    buildInputs = with pkgs; [
      webkitgtk_4_1
      gtk3
      glib
      dbus
    ];
    unpackPhase = "dpkg-deb -x $src .";
    installPhase = ''
      mkdir -p $out
      cp -r usr/* $out/
    '';
  };

  alcom-wrapper = pkgs.writeShellScriptBin "alcom" ''
    export GDK_BACKEND=x11
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    exec ${alcom-pkg}/bin/ALCOM "$@"
  '';

  alcom-desktop = pkgs.makeDesktopItem {
    name = "alcom";
    desktopName = "ALCOM";
    comment = "VRChat Package Manager";
    exec = "alcom";
    terminal = false;
    categories = [ "Development" ];
  };
in
{
  options.programs.vrchat.enable = mkEnableOption "VRChat avatar tools (ALCOM + Unity Hub)";
  config = mkIf config.programs.vrchat.enable {
    environment.systemPackages = with pkgs; [
      alcom-pkg
      alcom-wrapper
      alcom-desktop
      unityhub
    ];
  };
}

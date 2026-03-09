{ config, lib, pkgs, ... }:
with lib;
let
  alcom-pkg = pkgs.stdenv.mkDerivation {
    pname = "alcom";
    version = "1.1.5";

    src = pkgs.fetchurl {
      url = "https://github.com/vrc-get/vrc-get/releases/download/gui-v1.1.5/alcom_1.1.5_amd64.deb";
      sha256 = "sha256-18r01xc52yf4z7q7mdak0vb8agimm63s9hll7qmfw3n7nq5sdgvl";
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
      alcom-desktop
      unityhub
    ];
  };
}

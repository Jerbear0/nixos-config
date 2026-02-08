{ config, lib, pkgs, ... }:

with lib;

let
  # Wrapper for the ALCOM AppImage
  alcom-script = pkgs.writeShellScriptBin "alcom" ''
    set -euo pipefail

    # Find ALCOM AppImage (any version) at RUNTIME
    APPIMAGE=""
    for appimage in /etc/nixos/pkgs/alcom-*.AppImage; do
      if [ -f "$appimage" ]; then
        APPIMAGE="$appimage"
        break
      fi
    done

    if [ -z "$APPIMAGE" ]; then
      echo "ALCOM AppImage not found in /etc/nixos/pkgs/" >&2
      echo "Please download from: https://github.com/vrc-get/vrc-get/releases" >&2
      exit 1
    fi

    if [ ! -x "$APPIMAGE" ]; then
      chmod +x "$APPIMAGE" 2>/dev/null || true
    fi

    # Copy to /tmp so AppImage can self-update / create overlays if needed
    tmpAppImage="$(mktemp /tmp/alcom-XXXXXX.AppImage)"
    cp "$APPIMAGE" "$tmpAppImage"
    chmod +x "$tmpAppImage"

    exec ${pkgs.appimage-run}/bin/appimage-run "$tmpAppImage" "$@"
  '';
in
{
  options.programs.vrchat.enable = mkEnableOption "VRChat avatar tools (ALCOM + Unity Hub)";
  
  config = mkIf config.programs.vrchat.enable {
    environment.systemPackages = with pkgs; [
      alcom-script
      unityhub
    ];
  };
}
    

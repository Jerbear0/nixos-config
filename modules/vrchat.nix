{ config, lib, pkgs, ... }:  
  
with lib;  
  
let  
  # Wrapper for the ALCOM AppImage  
  alcom-script = pkgs.writeShellScriptBin "alcom" ''  
    set -euo pipefail  
  
    APPIMAGE="/etc/nixos/pkgs/alcom-1.1.5-x86_64.AppImage"  
  
    if [ ! -f "$APPIMAGE" ]; then  
      echo "ALCOM AppImage not found at: $APPIMAGE" >&2  
      exit 1  
    fi  
  
    if [ ! -x "$APPIMAGE" ]; then  
      # Just in case the file is not executable on the NixOS store  
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

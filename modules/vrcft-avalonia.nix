{ config, lib, pkgs, ... }:

let
  cfg = config.programs.vrcft-avalonia;
  
  vrcft-script = pkgs.writeShellScriptBin "vrcft-avalonia" ''
    # 1. Find ICU library path
    ICU_PATH=$(${pkgs.nix}/bin/nix-build --no-out-link '<nixpkgs>' -A icu)/lib
    export LD_LIBRARY_PATH="$ICU_PATH:$LD_LIBRARY_PATH"

    # 2. Find VRCFaceTracking AppImage (any version) at RUNTIME
    APPIMAGE_SOURCE=""
    for appimage in /etc/nixos/pkgs/VRCFaceTracking*.AppImage; do
      if [ -f "$appimage" ]; then
        APPIMAGE_SOURCE="$appimage"
        break
      fi
    done
    
    if [ -z "$APPIMAGE_SOURCE" ]; then
      echo "ERROR: No VRCFaceTracking AppImage found in /etc/nixos/pkgs/" >&2
      echo "Please download it from: https://github.com/benaclejames/VRCFaceTracking/releases" >&2
      exit 1
    fi
    
    # 3. Copy AppImage to /tmp so the sandbox can access it
    TEMP_APPIMAGE="/tmp/vrcft-avalonia-$(id -u).AppImage"
    
    if [ ! -f "$TEMP_APPIMAGE" ] || [ "$APPIMAGE_SOURCE" -nt "$TEMP_APPIMAGE" ]; then
      cp "$APPIMAGE_SOURCE" "$TEMP_APPIMAGE"
      chmod +x "$TEMP_APPIMAGE"
    fi
    
    # 4. Execute from /tmp
    exec ${pkgs.appimage-run}/bin/appimage-run "$TEMP_APPIMAGE" "$@"
  '';
in
{
  options.programs.vrcft-avalonia = {
    enable = lib.mkEnableOption "VRCFaceTracking.Avalonia via local AppImage";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      vrcft-script
    ];

    systemd.tmpfiles.rules = [
      "d /home/jay/.config/VRCFaceTracking 0755 jay users -"
    ];
  };
} 

{ config, lib, pkgs, ... }:  
  
let  
  cfg = config.programs.vrcft-avalonia;  
    
  vrcft-script = pkgs.writeShellScriptBin "vrcft-avalonia" ''  
    # 1. Find ICU library path  
    ICU_PATH=$(${pkgs.nix}/bin/nix-build --no-out-link '<nixpkgs>' -A icu)/lib  
    export LD_LIBRARY_PATH="$ICU_PATH:$LD_LIBRARY_PATH"  
  
    # 2. Copy AppImage to /tmp so the sandbox can access it  
    # This avoids the "bwrap: Can't chdir to /etc/nixos" error  
    TEMP_APPIMAGE="/tmp/vrcft-avalonia-$(id -u).AppImage"  
      
    if [ ! -f "$TEMP_APPIMAGE" ]; then  
      cp /etc/nixos/pkgs/VRCFaceTracking.Avalonia.1.1.1.0.AppImage "$TEMP_APPIMAGE"  
      chmod +x "$TEMP_APPIMAGE"  
    fi  
      
    # 3. Execute from /tmp  
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

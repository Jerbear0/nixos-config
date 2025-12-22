{ config, lib, pkgs, ... }:  
  
let  
  cfg = config.programs.VRCFT-Avalonia;  
  VRCFT-Avalonia = import ../pkgs/VRCFT-Avalonia.nix { inherit pkgs; };  
in {  
  options.programs.VRCFT-Avalonia = {  
    enable = lib.mkEnableOption "VRCFaceTracking Avalonia AppImage";  
  };  
  
  config = lib.mkIf cfg.enable {  
    # Make the program available in PATH  
    environment.systemPackages = [ VRCFT-Avalonia ];  
  
    # Create a desktop entry so it shows up in wofi/drun  
    environment.etc."xdg/applications/VRCFT-Avalonia.desktop".text = ''  
      [Desktop Entry]  
      Type=Application  
      Name=VRCFT Avalonia  
      Comment=VRCFaceTracking Avalonia GUI  
      Exec=VRCFT-Avalonia %u  
      Icon=VRCFT-Avalonia  
      Terminal=false  
      Categories=Utility;  
    '';  
  };  
}  


{ config, pkgs, lib, ... }:  
  
let  
  cfg = config.programs.vrcfacetracking;  
in  
{  
  options.programs.vrcfacetracking = {  
    enable = lib.mkEnableOption "VRCFaceTracking (Windows app via Wine)";  
  
    package = lib.mkOption {  
      type = lib.types.package;  
      default = pkgs.callPackage ../pkgs/vrcfacetracking.nix {  
        wine = pkgs.wineWowPackages.staging;  
      };  
      description = lib.mdDoc "Package providing VRCFaceTracking, typically the Windows release ZIP wrapped to run under Wine.";  
    };  
  };  
  
  config = lib.mkIf cfg.enable {  
    environment.systemPackages = [ cfg.package ];  
  };  
}  


# /etc/nixos/modules/discord-music-presence.nix  
{ config, pkgs, lib, ... }:  
  
let  
  cfg = config.services.discord-music-presence;  
  
  dmpPkg = import ../pkgs/discord-music-presence.nix {  
    inherit pkgs lib;  
  };  
in  
{  
  options.services.discord-music-presence = {  
    enable = lib.mkEnableOption "Discord Music Presence";  
  
    package = lib.mkOption {  
      type = lib.types.package;  
      default = dmpPkg;  
      description = "Package to use for discord-music-presence.";  
    };  
  
    extraArgs = lib.mkOption {  
      type = lib.types.listOf lib.types.str;  
      default = [];  
      description = "Extra CLI arguments for discord-music-presence.";  
    };  
  };  
  
  config = lib.mkIf cfg.enable {  
    # Make the package available on PATH  
    environment.systemPackages = [ cfg.package ];  
  
    # User service: runs in your login session and autostarts  
    systemd.user.services.discord-music-presence = {  
      description = "Discord Music Presence";  
  
      # These 3 lines are what make it "autostart":  
      # - It will start when your graphical session starts  
      # - It will stop when your graphical session stops  
      wantedBy = [ "graphical-session.target" ];  
      partOf   = [ "graphical-session.target" ];  
      after    = [ "graphical-session.target" ];  
  
      serviceConfig = {  
        ExecStart   = "${cfg.package}/bin/discord-music-presence ${lib.concatStringsSep " " cfg.extraArgs}";  
        Restart     = "on-failure";  
        RestartSec  = 5;  
      };  
    };  
  };  
}    

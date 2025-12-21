{ config, pkgs, ... }:  
  
{  
  wayland.windowManager.hyprland.settings = {  
    # Desktop monitors (from your monitor.conf)  
    monitor = [  
      "DP-6,3440x1440@165,0x0,auto"  
      "DP-4,2560x1440@60,3440x-985,auto,transform,3"  
    ];  
  
    # Desktop-specific autostart (no idle lock, different wallpaper, etc.)  
    exec-once = [  
      "swaybg -o \\* -i ~/Pictures/wallpaper.jpg -m fill"  
      "waybar &"  
      "mako &"  
      "nm-applet --indicator &"  
      "/usr/lib/polkit-kde-authentication-agent-1 &"  
      "systemctl --user import-environment &"  
      "hash dbus-update-activation-environment 2>/dev/null &"  
      "dbus-update-activation-environment --systemd &"  
    ];  
  
    # Desktop-specific binds (screenshots, etc.)  
    bind = [  
      ", Print, exec, grimblast copy area"  
      "CTRL, Print, exec, grimblast copy active"  
      "ALT, Print, exec, grimblast copy output"  
    ];  
  };  
}  

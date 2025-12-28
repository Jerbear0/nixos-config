{ config, pkgs, ... }:  
  
{  
  wayland.windowManager.hyprland.settings = {  
    # Laptop monitor (single internal display)  
    monitor = [  
      ",preferred,auto,auto"  
    ];  
  
    # Laptop-specific autostart  
    exec-once = [  
      "waybar &"  
      "mako &"  
      "nm-applet --indicator &"  
      "/usr/lib/polkit-kde-authentication-agent-1 &"  
      "systemctl --user import-environment &"  
      "hash dbus-update-activation-environment 2>/dev/null &"  
      "dbus-update-activation-environment --systemd &"  
      "swayidle -w timeout 300 'swaylock -f -c 000000' before-sleep 'swaylock -f -c 000000'"  
      "discord-music-presence &"
    ];  
  
    # Laptop-specific binds (screenshots, etc.)  
    bind = [  
      ", Print, exec, grimblast copy area"  
      "CTRL, Print, exec, grimblast copy active"  
      "ALT, Print, exec, grimblast copy output"  
    ];  
  };  
}  

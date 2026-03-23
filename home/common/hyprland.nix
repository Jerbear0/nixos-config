{ config, pkgs, lib, inputs, ... }:  
  
let  
  # Directory where this file lives: /etc/nixos/home/common  
  # Using a relative Nix path keeps the flake relocatable.  
  wallpaperDir = ./.;  # == /etc/nixos/home/common  
  
  # All files in that dir  
  allFiles = builtins.attrNames (builtins.readDir wallpaperDir);  
  
  # Only keep jpg / jpeg / png (case-insensitive)  
  isImage = name:  
    let  
      lower = lib.toLower name;  
    in  
      lib.hasSuffix ".jpg"  lower ||  
      lib.hasSuffix ".jpeg" lower ||  
      lib.hasSuffix ".png"  lower;  
  
  imageFiles  = builtins.filter isImage allFiles;  
  wallpaperPaths = map (name: "${wallpaperDir}/${name}") imageFiles;  
  
  # Hyprpaper's 'wallpaper' directives use "monitor,path".  
  # Using ",path" applies to all monitors.  
  wallpaperAssignments = map (path: ",${path}") wallpaperPaths;  
  
in  

{  
  wayland.windowManager.hyprland = {  
    enable = true;  
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  
    settings = {  
      # ===== Variables / Programs =====  
      "$terminal" = "alacritty --config-file /etc/nixos/configs/alacritty.toml";  
      "$filemanager" = "dolphin";  
      "$applauncher" = "caelestia:launcher";  
      "$mainMod" = "SUPER";  
      "$facetracking" = "/etc/nixos/modules/facetracking";

      # ===== Environment =====  
      envd = [  
        "HYPRCURSOR_SIZE,24"  
        "XCURSOR_SIZE,24"  
        "QT_CURSOR_SIZE,24"  
      ];  
  
      env = [  
        "ELECTRON_OZONE_PLATFORM_HINT,auto"  
      ];  
  
      # ===== General =====  
      general = {  
        gaps_in = 3;  
        gaps_out = 20;  
        border_size = 3;  
        "col.active_border" = "rgba(82dcccff)";  # cachylgreen  
        "col.inactive_border" = "rgba(182545ff)"; # cachymblue  
        layout = "scrolling";  
  
        snap = {  
          enabled = true;  
        };  
      };  
  
      # ===== Decoration =====  
      decoration = {  
        active_opacity = 1;  
        rounding = 20;  
  
        blur = {  
          size = 15;  
          passes = 2;  
          xray = true;  
        };  
  
        shadow = {  
          enabled = false;  
        };  
      };  
  
      # ===== Animations =====  
      animations = {  
        enabled = true;  
  
        bezier = [  
          "overshot, 0.13, 0.99, 0.29, 1.1"  
        ];  
  
        animation = [  
          "windowsIn, 1, 4, overshot, slide"  
          "windowsOut, 1, 5, default, popin 80%"  
          "border, 1, 5, default"  
          "workspacesIn, 1, 6, overshot, slide"  
          "workspacesOut, 1, 6, overshot, slidefade 80%"  
        ];  
      };  
  
      # ===== Input =====  
      input = {  
        follow_mouse = 1;  
        float_switch_override_focus = 2;  
      };  
  
      # ===== Gestures =====  
      gesture = [  
        "4, horizontal, workspace"  
        "3, down, close"  
        "3, up, fullscreen"  
        "3, left, float"  
      ];  
  
      # ===== Group =====  
      group = {  
        "col.border_active" = "rgba(007d6fff)";    # cachydgreen  
        "col.border_inactive" = "rgba(82dcccff)";  # cachylgreen  
        "col.border_locked_active" = "rgba(00aa84ff)";   # cachymgreen  
        "col.border_locked_inactive" = "rgba(111826ff)"; # cachydblue  
  
        groupbar = {  
          font_family = "Fira Sans";  
          text_color = "rgba(111826ff)";  
          "col.active" = "rgba(007d6fff)";  
          "col.inactive" = "rgba(82dcccff)";  
          "col.locked_active" = "rgba(00aa84ff)";  
          "col.locked_inactive" = "rgba(111826ff)";  
        };  
      };  
  
      # ===== Misc =====  
      misc = {  
        font_family = "Fira Sans";  
        splash_font_family = "Fira Sans";  
        disable_hyprland_logo = true;  
        "col.splash" = "rgba(82dcccff)";  
        background_color = "rgba(111826ff)";  
        enable_swallow = true;  
        swallow_regex = "^(nautilus|nemo|thunar|btrfs-assistant.)$";  
        focus_on_activate = true;  
        vrr = 0; 
        disable_hyprland_guiutils_check = true; 
      };  
  
      # ===== Render =====  
      render = {  
        direct_scanout = true;  
      };  
  
      # ===== Dwindle Layout =====  
      dwindle = {  
        special_scale_factor = 0.8;  
        pseudotile = true;  
        preserve_split = true;  
      };  
  
      # ===== Master Layout =====  
      master = {  
        new_status = "master";  
        special_scale_factor = 0.8;  
      };  
  
      # ===== Binds Config =====  
      binds = {  
        allow_workspace_cycles = 1;  
        workspace_back_and_forth = 1;  
        workspace_center_on = 1;  
        movefocus_cycles_fullscreen = true;  
        window_direction_monitor_fallback = true;  
      };  
  
      # ===== Keybinds =====  
      bind = [  
        # Launch apps  
        "$mainMod, RETURN, exec, $terminal"  
        "$mainMod, E, exec, $filemanager"  
        "$mainMod, SPACE, global, $applauncher"  
        "$mainMod, W, exec, firefox"  
        "Control&ALT, V, execr, $facetracking" 
  
        # Window management  
        "$mainMod, Q, killactive,"  
        "$mainMod SHIFT, M, exec, loginctl terminate-user \"\""  
        "$mainMod, V, togglefloating,"  
        "$mainMod, F, fullscreen"  
        "$mainMod, Y, pin"
        "$mainMod, J, layoutmsg, togglesplit"  
  
        # Grouping  
        "$mainMod, K, togglegroup,"  
        "$mainMod, Tab, changegroupactive, f"  
  
        # Toggle gaps  
        "$mainMod SHIFT, G, exec, hyprctl --batch \"keyword general:gaps_out 20;keyword general:gaps_in 3\""  
        "$mainMod, G, exec, hyprctl --batch \"keyword general:gaps_out 0;keyword general:gaps_in 0\""  
  
        # Lock screen  
        "$mainMod, L, exec, swaylock -f -c 000000"  
  
        # Reload quickshell 
         "$mainMod, O, exec, sh -c 'pkill quickshell; sleep 0.5; caelestia-shell &'"  
  
        # Move focus  
        "$mainMod, left, movefocus, l"  
        "$mainMod, right, movefocus, r"  
        "$mainMod, up, movefocus, u"  
        "$mainMod, down, movefocus, d"  
  
        # Move window  
        "$mainMod SHIFT, left, movewindow, l"  
        "$mainMod SHIFT, right, movewindow, r"  
        "$mainMod SHIFT, up, movewindow, u"  
        "$mainMod SHIFT, down, movewindow, d"   
  
        # Workspaces  
        "$mainMod, 1, workspace, 1"  
        "$mainMod, 2, workspace, 2"  
        "$mainMod, 3, workspace, 3"  
        "$mainMod, 4, workspace, 4"  
        "$mainMod, 5, workspace, 5"  
        "$mainMod, 6, workspace, 6"  
        "$mainMod, 7, workspace, 7"  
        "$mainMod, 8, workspace, 8"  
        "$mainMod, 9, workspace, 9"  
        "$mainMod, 0, workspace, 10"  
  
        # Scroll workspaces  
        "$mainMod, PERIOD, workspace, e+1"  
        "$mainMod, COMMA, workspace, e-1"  
        "$mainMod, mouse_down, workspace, e+1"  
        "$mainMod, mouse_up, workspace, e-1"  
        "$mainMod, slash, workspace, previous"  
  
        # Move to workspace  
        "$mainMod CTRL, 1, movetoworkspace, 1"  
        "$mainMod CTRL, 2, movetoworkspace, 2"  
        "$mainMod CTRL, 3, movetoworkspace, 3"  
        "$mainMod CTRL, 4, movetoworkspace, 4"  
        "$mainMod CTRL, 5, movetoworkspace, 5"  
        "$mainMod CTRL, 6, movetoworkspace, 6"  
        "$mainMod CTRL, 7, movetoworkspace, 7"  
        "$mainMod CTRL, 8, movetoworkspace, 8"  
        "$mainMod CTRL, 9, movetoworkspace, 9"  
        "$mainMod CTRL, 0, movetoworkspace, 10"  
        "$mainMod CTRL, left, movetoworkspace, -1"  
        "$mainMod CTRL, right, movetoworkspace, +1"  
  
        # Move to workspace silently  
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"  
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"  
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"  
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"  
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"  
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"  
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"  
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"  
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"  
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"  
  
        # Special workspace  
        "$mainMod, minus, movetoworkspace, special"  
        "$mainMod, equal, togglespecialworkspace, special"  
        "$mainMod, F1, togglespecialworkspace, scratchpad"  
        "$mainMod ALT SHIFT, F1, movetoworkspacesilent, special:scratchpad"  
  
        # Quick resize  
        "$mainMod CTRL SHIFT, right, resizeactive, 15 0"  
        "$mainMod CTRL SHIFT, left, resizeactive, -15 0"  
        "$mainMod CTRL SHIFT, up, resizeactive, 0 -15"  
        "$mainMod CTRL SHIFT, down, resizeactive, 0 15"  
        "$mainMod CTRL SHIFT, l, resizeactive, 15 0"  
        "$mainMod CTRL SHIFT, h, resizeactive, -15 0"  
        "$mainMod CTRL SHIFT, k, resizeactive, 0 -15"  
        "$mainMod CTRL SHIFT, j, resizeactive, 0 15"  
      ];   
  
      # Mouse binds  
      bindm = [  
        "$mainMod, mouse:272, movewindow"  
        "$mainMod, mouse:273, resizewindow"  
      ];  
  
      # Volume / brightness / media  
      bindel = [  
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"  
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"  
        ", XF86AudioMute, exec, pactl set-mute @DEFAULT_SINK@ toggle"  
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"  
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"  
      ];  
  
      bindl = [  
        ", XF86AudioPlay, exec, playerctl play-pause"  
        ", XF86AudioNext, exec, playerctl next"  
        ", XF86AudioPrev, exec, playerctl previous"  
      ];  
  
      # Window rules  
      extraConfig = ''
        windowrule = float on, match:class ^(org\.pulseaudio\.pavucontrol)$
        windowrule = float on, match:class ^()$, match:title ^(Picture in picture)$
        windowrule = float on, match:class ^()$, match:title ^(Save File)$
        windowrule = float on, match:class ^()$, match:title ^(Open File)$
        windowrule = float on, match:class ^(LibreWolf)$, match:title ^(Picture-in-Picture)$
        windowrule = float on, match:class ^(blueman-manager)$
        windowrule = float on, match:class ^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$
        windowrule = float on, match:class ^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org\.kde\.polkit-kde-authentication-agent-1)(.*)$
        windowrule = float on, match:class ^(zenity)$
        windowrule = float on, match:class ^()$, match:title ^(Steam - Self Updater)$
        windowrule = float on, match:class floating
        windowrule = size 2000 1200, match:class floating
        windowrule = opacity 0.92, match:class ^(thunar|nemo)$
        windowrule = opacity 0.96, match:class ^(discord|armcord|webcord)$
        windowrule = float on, match:title ^(Picture-in-Picture)$
        windowrule = size 960 540, match:title ^(Picture-in-Picture)$
        windowrule = move 25%-, match:title ^(Picture-in-Picture)$
        windowrule = float on, match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$
        windowrule = move 25%-, match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$
        windowrule = size 960 540, match:title ^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$
        windowrule = pin on, match:title ^(danmufloat)$
        windowrule = rounding 5, match:title ^(danmufloat|termfloat)$
        windowrule = animation slide right, match:class ^(kitty|Alacritty)$
        windowrule = no_blur on, match:class ^(org\.mozilla\.firefox)$
        windowrule = border_size 2, match:float true, match:workspace w[fv1-10]
        windowrule = border_color rgba(01ccffff), match:float true, match:workspace w[fv1-10]
        windowrule = rounding 20, match:float true, match:workspace w[fv1-10]
        windowrule = border_size 3, match:float false, match:workspace f[1-10]
        windowrule = rounding 20, match:float false, match:workspace f[1-10]
        windowrule = suppress_event maximize, match:class .*
        windowrule = suppress_event fullscreen, match:title ^(Star Citizen)$
      '';  
  
      # Workspace rules  
      workspace = [  
        "w[tv1-10], gapsout:20, gapsin:3"  
        "f[1], gapsout:20, gapsin:3"  
      ];  
  
      # Layer rules  
      layerrule = [  
        "animation slide top, match:namespace logout_dialog"
        "animation fade 50%, match:namespace wallpaper"
        "no_anim on, match:namespace quickshell-bar"
        "no_anim on, match:namespace quickshell-dashboard"
        "no_anim on, match:namespace quickshell-dash-trigger"
      ];  
    };  
  };  

  ################################  
  ## Hyprpaper: wallpapers      ##  
  ################################  
  services.hyprpaper = {  
    enable = true;  
    settings = {  
      preload = wallpaperPaths;  
  
      # If no images are found, fall back to a default NixOS wallpaper  
      wallpaper =  
        if wallpaperAssignments == [] then  
          [ ",/run/current-system/sw/share/backgrounds/nixos/nix-wallpaper.png" ]  
        else  
          wallpaperAssignments;  
    };  
  };  
}

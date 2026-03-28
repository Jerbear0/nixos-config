{ ... }:

{
  wayland.windowManager.hyprland.settings = {
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

    workspace = [
      "w[tv1-10], gapsout:20, gapsin:3"
      "f[1], gapsout:20, gapsin:3"
    ];

    layerrule = [
      "animation slide top, match:namespace logout_dialog"
      "animation fade 50%, match:namespace wallpaper"
      "no_anim on, match:namespace quickshell-bar"
      "no_anim on, match:namespace quickshell-dashboard"
      "no_anim on, match:namespace quickshell-dash-trigger"
    ];
  };
}

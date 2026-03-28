{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 3;
      gaps_out = 20;
      border_size = 3;
      "col.active_border" = "rgba(82dcccff)";
      "col.inactive_border" = "rgba(182545ff)";
      layout = "scrolling";

      snap = {
        enabled = true;
      };
    };

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

    group = {
      "col.border_active" = "rgba(007d6fff)";
      "col.border_inactive" = "rgba(82dcccff)";
      "col.border_locked_active" = "rgba(00aa84ff)";
      "col.border_locked_inactive" = "rgba(111826ff)";

      groupbar = {
        font_family = "Fira Sans";
        text_color = "rgba(111826ff)";
        "col.active" = "rgba(007d6fff)";
        "col.inactive" = "rgba(82dcccff)";
        "col.locked_active" = "rgba(00aa84ff)";
        "col.locked_inactive" = "rgba(111826ff)";
      };
    };
  };
}

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # Launch apps
      "$mainMod, RETURN, exec, $terminal"
      "$mainMod, E, exec, $filemanager"
      "$mainMod, SPACE, global, $applauncher"
      "$mainMod, W, exec, firefox"
      "Control&ALT, V, execr, /etc/nixos/modules/facetracking"

      # Window management
      "$mainMod, Q, killactive,"
      "$mainMod SHIFT, M, exec, loginctl terminate-user \"\""
      "$mainMod, V, togglefloating,"
      "$mainMod, F, fullscreen"
      "$mainMod, Y, pin"
      "$mainMod, J, layoutmsg, move +col"
      "$mainMod, K, layoutmsg, swapcol 1"

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
  };
}

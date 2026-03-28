{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./appearance.nix
    ./keybinds.nix
    ./rules.nix
    ./wallpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    settings = {
      "$terminal" = "alacritty";
      "$filemanager" = "dolphin";
      "$applauncher" = "caelestia:launcher";
      "$mainMod" = "SUPER";

      envd = [
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_SIZE,24"
        "QT_CURSOR_SIZE,24"
      ];

      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      input = {
        follow_mouse = 1;
        float_switch_override_focus = 2;
      };

      gesture = [
        "4, horizontal, workspace"
        "3, down, close"
        "3, up, fullscreen"
        "3, left, float"
      ];

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
        disable_watchdog_warning = true;
        disable_splash_rendering = true;
      };

      render = {
        direct_scanout = true;
      };

      dwindle = {
        special_scale_factor = 0.8;
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
        special_scale_factor = 0.8;
      };

      binds = {
        allow_workspace_cycles = 1;
        workspace_back_and_forth = 1;
        workspace_center_on = 1;
        movefocus_cycles_fullscreen = true;
        window_direction_monitor_fallback = true;
      };
    };
  };
}

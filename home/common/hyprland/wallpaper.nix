{ config, pkgs, lib, ... }:

let
  # Look for wallpapers in the parent directory (home/common/)
  wallpaperDir = ./..;

  allFiles = builtins.attrNames (builtins.readDir wallpaperDir);

  isImage = name:
    let
      lower = lib.toLower name;
    in
      lib.hasSuffix ".jpg" lower ||
      lib.hasSuffix ".jpeg" lower ||
      lib.hasSuffix ".png" lower;

  imageFiles = builtins.filter isImage allFiles;
  wallpaperPaths = map (name: "${wallpaperDir}/${name}") imageFiles;
  wallpaperAssignments = map (path: ",${path}") wallpaperPaths;

in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = wallpaperPaths;

      wallpaper =
        if wallpaperAssignments == [] then
          [ ",/run/current-system/sw/share/backgrounds/nixos/nix-wallpaper.png" ]
        else
          wallpaperAssignments;
    };
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.baballonia;

  baballonia-unpacked =
    if cfg.package == "stable" then
      pkgs.callPackage ../pkgs/baballonia-unpacked.nix { }
    else if cfg.package == "rc2-ml4" then
      pkgs.callPackage ../pkgs/baballonia-rc2-src.nix { mlVersion = "4"; }
    else if cfg.package == "rc2-ml5" then
      pkgs.callPackage ../pkgs/baballonia-rc2-src.nix { mlVersion = "5"; }
    else
      throw "programs.baballonia.package: unknown value '${cfg.package}', expected stable | rc2-ml4 | rc2-ml5";

  # For source-built packages, the binary is at $out/bin/Baballonia.Desktop.
  # For the stable tarball it lives under opt/baballonia/.
  exePath =
    if cfg.package == "stable"
    then "${baballonia-unpacked}/opt/baballonia/Baballonia.Desktop"
    else "${baballonia-unpacked}/bin/Baballonia.Desktop";

  baballonia-uvc-fhs = pkgs.callPackage ../pkgs/baballonia-uvc-fhs.nix {
    inherit baballonia-unpacked exePath;
  };

  baballonia-uvc-fixed = pkgs.writeShellScriptBin "baballonia-uvc" ''
    set -eu
    cd /
    exec "${baballonia-uvc-fhs}/bin/baballonia-uvc" "$@"
  '';
in
{
  options.programs.baballonia = {
    enable = lib.mkEnableOption "Baballonia VR eye and face tracking";

    package = lib.mkOption {
      type    = lib.types.enum [ "stable" "rc2-ml4" "rc2-ml5" ];
      default = "stable";
      description = ''
        Which Baballonia build to use.
          stable   – pre-built tarball (default, pure build, no extra flags needed)
          rc2-ml4  – RC2 built from source with Microsoft.ML 4.0.2 + OnnxRuntime 1.18 (CPU)
          rc2-ml5  – RC2 built from source with Microsoft.ML 5.0.0 + OnnxRuntime 1.20 (CPU)

        For rc2-ml4 / rc2-ml5: run fetch-deps once with --impure to generate the
        nuget lockfiles, then commit them. After that, nixos-rebuild needs no extra flags.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      baballonia-uvc-fixed
    ];

    systemd.tmpfiles.rules = [
      "d /home/jay/ProjectBabble 0755 jay users -"
    ];

    environment.etc."xdg/share/applications/baballonia-uvc.desktop".text = ''
      [Desktop Entry]
      Name=Baballonia (with Libuvc)
      Comment=Babble VR eye and face tracking with UVC backend
      Exec=baballonia-uvc
      Terminal=false
      Type=Application
      Categories=Utility;
      Icon=${baballonia-unpacked}/opt/baballonia/Assets/Icon_512x512.png
    '';

    services.udev.extraRules = ''
      # Bigscreen Beyond Headset (35bd:0101)
      SUBSYSTEM=="usb", ATTR{idVendor}=="35bd", ATTR{idProduct}=="0101", MODE="0660", TAG+="uaccess", GROUP="video"

      # Bigscreen Bigeye Camera (35bd:0202)
      SUBSYSTEM=="usb", ATTR{idVendor}=="35bd", ATTR{idProduct}=="0202", MODE="0660", TAG+="uaccess", GROUP="video"

      # All Bigscreen USB devices
      SUBSYSTEM=="usb", ATTR{idVendor}=="35bd", MODE="0660", TAG+="uaccess", GROUP="video"

      # Video devices from Bigscreen
      SUBSYSTEM=="video4linux", ATTRS{idVendor}=="35bd", MODE="0660", TAG+="uaccess", GROUP="video"

      # HID devices from Bigscreen
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", MODE="0660", TAG+="uaccess", GROUP="video"

      # Espressif ESP32-S3 Babble Tracker
      SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", TAG+="uaccess", GROUP="dialout"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="303a", ATTR{idProduct}=="8000", MODE="0660", GROUP="video"
    '';
  };
}

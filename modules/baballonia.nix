{ config, lib, pkgs, ... }:  
  
let  
  cfg = config.programs.baballonia;  
  
  baballonia-unpacked = pkgs.callPackage ../pkgs/baballonia-unpacked.nix { };  
  
  # FHS env wrapper which now also merges Libuvc internally  
  baballonia-uvc-fhs = pkgs.callPackage ../pkgs/baballonia-uvc-fhs.nix {  
    inherit baballonia-unpacked;  
  };  
  
  # Small wrapper that forces starting from / so bwrap's --chdir "$(pwd)" is always safe  
  baballonia-uvc-fixed = pkgs.writeShellScriptBin "baballonia-uvc" ''  
    set -eu  
    cd /  
    exec "${baballonia-uvc-fhs}/bin/baballonia-uvc" "$@"  
  '';  
in  
{  
  options.programs.baballonia.enable =  
    lib.mkEnableOption "Baballonia VR eye and face tracking";  
  
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
    '';  
  };  
}   

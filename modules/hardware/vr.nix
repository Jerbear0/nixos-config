{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../patching/vr.nix
  ];

  home-manager.users.jay = import ./home_manager/vr.nix;

  users.users.jay = {
    packages = with pkgs; [
      v4l-utils
      xrgears
      xrizer-patched
      motoc
      wlx-overlay-s
      libsurvive
      wayvr-dashboard
      steamcmd
    ];
  };

  services = {
    monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
      package = pkgs.monado;
    };

  };

  environment.systemPackages = with pkgs; [ basalt-monado ];

  systemd.user.services = {
    monado = {
      environment = {
        XRT_LOG = "debug";
        XRT_COMPOSITOR_COMPUTE = "1";
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_DESIRED_MODE = "1";
        XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";
        LH_HANDTRACKING = "on";
        IPC_EXIT_WHEN_IDLE = "on";
        IPC_EXIT_WHEN_IDLE_DELAY_MS = "10000";
      };
    };

    wlx-overlay-s = {
      description = "VR wlx-overlay-s";
      path = [ pkgs.wayvr-dashboard ];
      serviceConfig = {
        ExecStart = "${pkgs.wlx-overlay-s}/bin/wlx-overlay-s";
        Restart = "on-abnormal";
      };
      bindsTo = [ "monado.service" ];
      partOf = [ "monado.service" ];
      after = [ "monado.service" ];
      upheldBy = [ "monado.service" ];
      unitConfig.ConditionUser = "!root";
    };
  };

  services.udev.extraRules = ''
    # Bigscreen Beyond Headset
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", TAG+="uaccess", GROUP="video"
    # Bigscreen Bigeye Camera
    SUBSYSTEM=="usb", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", TAG+="uaccess", GROUP="video", SYMLINK+="bigeye0"
    # Bigscreen Beyond Audio Strap
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", TAG+="uaccess", GROUP="video"
    # Bigscreen Beyond Firmware Mode
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", TAG+="uaccess", GROUP="video"
  '';
}

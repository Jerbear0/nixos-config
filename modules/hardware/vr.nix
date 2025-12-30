{ config, lib, pkgs, nixalt, unstable, inputs, ... }:

{

  imports = [
#    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
    ../patching/vr.nix
  ];
  home-manager.users.jay = import ./home_manager/vr.nix;

  users.users.jay = {
    packages = with pkgs; [
      v4l-utils # cameras
      xrgears # testing, just in case
      # opencomposite
      # xrizer
      xrizer-patched
      # xrizer-patched2
      # outoftree.pkgs.${pkgs.system}.xrizer
      motoc
      # index_camera_passthrough
      wlx-overlay-s
      # wlx-overlay-s_patched
      # outoftree.pkgs.${pkgs.system}.wlx-overlay-s
      libsurvive
      wayvr-dashboard
      # outoftree.pkgs.${pkgs.system}.wayvr-dashboard
      # outoftree.pkgs.${pkgs.system}.vrcadvert
      # oscavmgr
      # outoftree.pkgs.${pkgs.system}.oscavmgr
      # outoftree.pkgs.${pkgs.system}.resolute
      # outoftree.pkgs.${pkgs.system}.monado-vulkan-layers
      # outoftree.pkgs.${pkgs.system}.xrbinder

      steamcmd # For BSB
      # BSB2e
      # outoftree.pkgs.${pkgs.system}.go-bsb-cams
      # outoftree.pkgs.${pkgs.system}.baballonia
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
        # AMD_VULKAN_ICD = "RADV";
        XRT_COMPOSITOR_COMPUTE = "1";
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_DESIRED_MODE = "1"; # ensure 90 Hz  
        # VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
        XRT_COMPOSITOR_SCALE_PERCENTAGE="140";
        # XRT_COMPOSITOR_SCALE_PERCENTAGE="160";
        # U_PACING_COMP_MIN_TIME_MS = "3";
        # U_PACING_APP_IMMEDIATE_WAIT_FRAME_RETURN = "on";
        LH_HANDTRACKING = "on";
        # IPC_EXIT_ON_DISCONNECT = "on"; # kill when a client disconnects
        IPC_EXIT_WHEN_IDLE = "on"; # kill on idle! :)
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
    # Bigscreen Beyond
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", TAG+="uaccess", GROUP="video"
    # Bigscreen Bigeye
    SUBSYSTEM=="usb", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", TAG+="uaccess", GROUP="video", SYMLINK+="bigeye0"
    # SUBSYSTEM=="video4linux", SUBSYSTEMS=="usb", DRIVERS=="uvcvideo", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", TAG+="uaccess", GROUP="video"
    # Bigscreen Beyond Audio Strap
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", TAG+="uaccess", GROUP="video"
    # Bigscreen Beyond Firmware Mode?
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", TAG+="uaccess", GROUP="video"
  '';
}

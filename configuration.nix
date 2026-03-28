{ config, pkgs, lib, inputs, ... }:  
 
{  
  imports = [   
    ./modules/hardware/vr.nix  
    ./modules/baballonia.nix  
    ./modules/vrcft-avalonia.nix 
    ./modules/vrchat.nix  
  ];  

  nixpkgs.overlays = [
    inputs.nix-citizen.overlays.default
  ];

  ############################  
  # Bootloader  
  ############################  
  
  boot.loader.systemd-boot.enable = true;  
  boot.loader.efi.canTouchEfiVariables = true;  
  
  ############################  
  # Locale / Time  
  ############################  
  
  time.timeZone = "America/Toronto";  
  i18n.defaultLocale = "en_CA.UTF-8";  
  
  services.xserver.xkb = {  
    layout = "us";  
    variant = "";  
  };  
  
  ############################  
  # Users / Groups  
  ############################  
  
  users.groups.video = {};  
  
  users.users.jay = {  
    isNormalUser = true;  
    description = "jay";  
    extraGroups = [ "networkmanager" "wheel" "video" "dialout" ];  
    packages = [ ];  
  };  

  ############################  
  # Nix settings  
  ############################  
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config = {  
    allowUnfree = true;  
    nvidia.acceptLicense = true;  
  };   

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  xdg.portal = {  
    enable = true;  
    xdgOpenUsePortal = false;  
    extraPortals = [  
      pkgs.xdg-desktop-portal-hyprland    
    ];  
  };  

  ############################  
  # System packages  
  ############################  

  environment.systemPackages = with pkgs; [  
    alsa-utils  
    appimage-run  
    baobab
    btop  
    brightnessctl  
    bs-manager
    bumblebee  
    cabextract  
    darktable
    discord
    element-desktop 
    esptool 
    fastfetch  
    firefox
    gcr
    git
    glib
    libsecret
    obsidian
    goverlay  
    gparted
    hyprutils  
    kdePackages.dolphin  
    kitty 
    libreoffice 
    logseq
    lshw 
    lug-helper 
    lutris  
    mangohud
    nmap 
    pavucontrol  
    polkit  
    primus
    prismlauncher  
    protonplus
    protonup-qt  
    psmisc  
    p7zip 
    python3
    r2modman
    ranger 
    spotify  
    star-citizen
    steam 
    steamcmd 
    steam-run
    stress-ng
    unityhub  
    tmux  
    vim 
    vlc
    vrc-get 
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    wget  
    winetricks  
    wineWowPackages.staging  
    xdg-desktop-portal-hyprland  
    xdg-utils
    xorg.xrandr
    xsensors
    (pkgs.symlinkJoin {
       name = "orca-slicer";
       paths = [ pkgs.orca-slicer ];
       buildInputs = [ pkgs.makeWrapper ];
       postBuild = ''
         wrapProgram $out/bin/orca-slicer \
           --set GBM_BACKEND dri \
           --set __GLX_VENDOR_LIBRARY_NAME mesa \
           --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
           --set MESA_LOADER_DRIVER_OVERRIDE zink \
           --set GALLIUM_DRIVER zink \
           --set WEBKIT_DISABLE_DMABUF_RENDERER 1
       '';
     })
    (python311.withPackages (ps: with ps; [
      tkinter
      pip
      virtualenv
    ]))

  (callPackage ./pkgs/discord-music-presence.nix { }) 
  ];  
  
  
  ############################  
  # Fonts  
  ############################  
  
  fonts.packages = with pkgs; [  
    font-awesome  
    fira
    noto-fonts  
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono  
    nerd-fonts.fira-code  
    nerd-fonts.symbols-only
  ];
 
  ############################  
  # Programs  
  ############################  
  
  programs.hyprland.enable = true; 
  
  programs.steam = {  
    enable = true;  
  
    package = pkgs.steam.override {  
      extraPkgs = pkgs: with pkgs; [  
      keyutils
      libpng
      libpulseaudio
      libvorbis
      libxml2
      mangohud
      SDL2
      stdenv.cc.cc.lib
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver 
      (pkgs.runCommand "libxml2-compat" {} ''
        mkdir -p $out/lib
        ln -s ${pkgs.libxml2}/lib/libxml2.so.16 $out/lib/libxml2.so.2
      '')
      ];  
    };   

    extraCompatPackages = with pkgs; [  
      gamescope  
      proton-ge-bin  
    ];  
 
    remotePlay.openFirewall = true;  
    dedicatedServer.openFirewall = true;  
    localNetworkGameTransfers.openFirewall = true;  
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "0";
    # Add these for gamescope:
    VK_DEVICE_SELECT = "0";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
  };

  security.wrappers.bwrap = {
    source = "${pkgs.bubblewrap}/bin/bwrap";
    setuid = true;
    owner = "root";
    group = "root";
  };
  security.unprivilegedUsernsClone = true;

  programs.obs-studio = {  
    enable = true;     

  package = pkgs.obs-studio.override {  
    cudaSupport = true;  
  };
  
    plugins = with pkgs.obs-studio-plugins; [  
      wlrobs  
      obs-backgroundremoval  
      obs-pipewire-audio-capture  
      obs-gstreamer  
      obs-vkcapture  
      # obs-vaapi is not needed for Nvidia  
    ];  
  }; 

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
    package = pkgs.gamescope.override {
      enableExecutable = true;
    };
  };  
  programs.steam.gamescopeSession.enable = true;
  programs.vrcft-avalonia.enable = true;    
  programs.baballonia.enable = true;  
  programs.vrchat.enable = true;    
  programs.firefox.enable = true;   

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glibc
  ];

  ############################  
  # Audio (PipeWire + WirePlumber)  
  ############################  
  
  services.pulseaudio.enable = false;  
  
  security.rtkit.enable = true;  
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };   
 
  ############################  
  # Services  
  ############################  
  
  services.udev.enable = true;  
  services.openssh.enable = true;   
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;  
  services.udisks2.enable = true;
  services.gvfs.enable = true; 

  ############################  
  # System state version  
  ############################  
  
  system.stateVersion = "25.11";  
}  

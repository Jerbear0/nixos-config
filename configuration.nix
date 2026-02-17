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
#  nix.settings.sandbox = false;  
  nixpkgs.config = {  
    allowUnfree = true;  
    nvidia.acceptLicense = true;  
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
    bumblebee  
    cabextract  
    darktable
    discord  
    fastfetch  
    firefox   
    git  
    glib
    goverlay  
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
    unityhub  
    tmux  
    vim  
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    wget  
    winetricks  
    wineWowPackages.staging  
    xdg-desktop-portal-hyprland  
    xdg-utils
    xsensors   
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
  };

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
    # jack.enable = true; # only if you ever need JACK  
};   
 
  ############################  
  # Services  
  ############################  
  
  services.udev.enable = true;  
  services.openssh.enable = true;   
  services.gnome.gnome-keyring.enable = true;  
 
  ############################  
  # System state version  
  ############################  
  
  system.stateVersion = "25.11";  
}  

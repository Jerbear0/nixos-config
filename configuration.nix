{ config, pkgs, lib, ... }:  
  
{  
  imports = [   
    ./modules/hardware/vr.nix  
    ./modules/baballonia.nix  
    ./modules/vrcft-avalonia.nix
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
  
  ############################  
  # System packages  
  ############################  

  environment.systemPackages = with pkgs; [  
    alsa-utils  
    appimage-run  
    btop  
    brightnessctl  
    bumblebee  
    cabextract  
    darktable
    discord  
    fastfetch  
    firefox  
    gamescope  
    git  
    goverlay  
    hyprutils  
    kdePackages.dolphin  
    kitty  
    lshw  
    lutris  
    mangohud
    obs-studio  
    pavucontrol  
    polkit  
    primus  
    protonup-qt  
    psmisc  
    p7zip  
    spotify  
    steam 
    steamcmd 
    steam-run  
    tmux  
    vim  
    wget  
    winetricks  
    wineWowPackages.staging  
    xdg-desktop-portal-hyprland  
    xsensors   
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

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      #obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
 
    hardware.opengl = {  
      enable = true;  
      driSupport32Bit = true;  
    };   

  programs.vrcft-avalonia.enable = true;    
  programs.baballonia.enable = true;  
  programs.steam.gamescopeSession.enable = true;  
 
  environment.sessionVariables.NIXOS_OZONE_WL = "0";  

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
  
  ############################  
  # System state version  
  ############################  
  
  system.stateVersion = "25.11";  
}  

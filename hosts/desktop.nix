{ config, pkgs, lib, inputs, ... }:  
  
{  
  imports = [
   ./drives/desktop-drives.nix
  ];

  ############################  
  # Host identity / networking  
  ############################ 
  
  networking.hostName = "nixos-desktop";  
  
  # Desktop uses NetworkManager for wired/wireless  
  networking.networkmanager.enable = true;  
  
  ############################
  # Desktop-only packages
  ############################

  environment.systemPackages = with pkgs; [
    claude-code
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
  ];

  ############################  
  # Graphics (NVIDIA desktop)  
  ############################  
  
  hardware.graphics = {  
    enable = true;  
    enable32Bit = true;  
    extraPackages = with pkgs; [  
      nvidia-vaapi-driver  
      libva-vdpau-driver 
      libvdpau-va-gl  
    ];  
  };  
  
  services.xserver.videoDrivers = [ "nvidia" ];  
  services.xserver.xrandrHeads = {
  "DP-6".primary = true;
  };
  
  hardware.nvidia = {  
    modesetting.enable = true;  
    powerManagement.enable = false;  
    powerManagement.finegrained = false;  
    open = true;  
    nvidiaSettings = true;  
    package = config.boot.kernelPackages.nvidiaPackages.stable;  
  
    # No PRIME section here unless the desktop actually has hybrid graphics.  
    # If it does, you can later add its *own* prime block with the desktop's PCI IDs.  
  };  
}   

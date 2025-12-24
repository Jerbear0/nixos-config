{ config, pkgs, lib, ... }:  
  
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
  # Graphics (NVIDIA desktop)  
  ############################  
  
  hardware.graphics.enable = true;  
  
  services.xserver.videoDrivers = [ "nvidia" ];  
  
  hardware.nvidia = {  
    modesetting.enable = true;  
    powerManagement.enable = false;  
    powerManagement.finegrained = false;  
    open = false;  
    nvidiaSettings = true;  
    package = config.boot.kernelPackages.nvidiaPackages.stable;  
  
    # No PRIME section here unless the desktop actually has hybrid graphics.  
    # If it does, you can later add its *own* prime block with the desktop's PCI IDs.  
  };  
}   

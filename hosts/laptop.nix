{ config, lib, pkgs, ... }:  
  
{  
  imports = [  
    ./drives/laptop-drives.nix  
    ../secrets/wifi-laptop.nix  
  ];  
  
  ############################  
  # Host identity / networking  
  ############################  
  
  networking.hostName = "nixos-laptop";  
  networking.wireless.enable = true;  
  
  ############################  
  # Graphics (NVIDIA laptop)  
  ############################  
  
  hardware.graphics.enable = true;  
  
  services.xserver.videoDrivers = [ "nvidia" ];  
  
  hardware.nvidia = {  
    modesetting.enable = true;  
    powerManagement.enable = false;  
    powerManagement.finegrained = false;  
    open = true;  
    nvidiaSettings = true;  
    package = config.boot.kernelPackages.nvidiaPackages.stable;  
  
    prime = {  
      intelBusId = "PCI:0:2:0";  
      nvidiaBusId = "PCI:1:0:0";  
    };  
  };   
}   

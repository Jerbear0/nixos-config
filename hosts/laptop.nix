{ config, lib, pkgs, ... }:  

let
  secrets = import ../secrets/wifi-laptop.nix;
in
{  
  imports = [  
    ./drives/laptop-drives.nix  
  ];  
  
  ############################  
  # Host identity / networking  
  ############################  
  
  networking.hostName = "nixos-laptop";  
  networking.wireless = {
    enable = true;
    networks = secrets.networks;
  };  

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

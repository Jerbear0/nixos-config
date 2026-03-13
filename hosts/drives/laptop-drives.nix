# /etc/nixos/hosts/drives/laptop-drives.nix  
{ config, lib, pkgs, modulesPath, ... }:  
  
{  
  imports = [  
    (modulesPath + "/installer/scan/not-detected.nix")  
  ];  
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "thunderbolt" "usbhid" ];  
  boot.initrd.kernelModules = [ ];  
  boot.kernelModules = [ "kvm-intel" ];  
  boot.extraModulePackages = [ ];  
  
  fileSystems."/" = {  
    device = "/dev/disk/by-uuid/dbd4367a-ba96-4b98-9d4f-bf927bbae6b9";  
    fsType = "ext4";  
  };  
  
  fileSystems."/boot" = {  
    device = "/dev/disk/by-uuid/5987-EAC2";  
    fsType = "vfat";  
    options = [ "fmask=0077" "dmask=0077" ];  
  };  
  
  swapDevices = [ ];  
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";  
  hardware.cpu.intel.updateMicrocode =  
    lib.mkDefault config.hardware.enableRedistributableFirmware;  
}  

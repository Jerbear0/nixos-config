{ config, lib, pkgs, ... }:  
  
{ 
  nixpkgs.overlays = [  
    (final: prev: {  
      xrizer-patched = prev.callPackage ../patching/xrizer-patched.nix { };  
    })  
  ]; 
}

{ pkgs, ... }:  
  
pkgs.appimageTools.wrapType2 {  
  pname = "VRCFT-Avalonia";  
  version = "1.1.1.0";  
  
  src = pkgs.fetchurl {  
    url = "https://github.com/dfgHiatus/VRCFaceTracking.Avalonia/releases/download/v1.1.1.0/VRCFaceTracking.Avalonia.1.1.1.0.AppImage";  
    sha256 = "sha256-0r44ir3d9h2bcczm8jimqd3jhkhn5li5ghka5wlcq2sznar2svx1";  
  };  
  
  extraPkgs = pkgs: [  
    pkgs.fuse  
    pkgs.alsa-lib  
    pkgs.fontconfig  
    pkgs.libGL  
    pkgs.xorg.libX11  
  ];  
}   

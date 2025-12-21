{ pkgs, lib, baballonia-unpacked }:  
  
let  
  # Backend: point directly to the DLL file next to this nix  
  baballonia-uvc-dll = ./Baballonia.LibuvcCapture.dll;  
  
  # Combine base Baballonia + Libuvc DLL into one tree  
  baballonia-with-uvc = pkgs.stdenv.mkDerivation {  
    pname = "baballonia-with-uvc";  
    version = baballonia-unpacked.version or "1.1.0.9rc4";  
  
    src = null;  
    dontUnpack = true;  
  
    installPhase = ''  
      set -eu  
  
      mkdir -p "$out/opt"  
  
      # Copy base Baballonia tree  
      cp -r "${baballonia-unpacked}/opt/baballonia" "$out/opt/"  
  
      # Make copied tree writable before we touch it  
      chmod -R u+rwX "$out/opt/baballonia"  
  
      # Copy the Libuvc DLL into Modules  
      mkdir -p "$out/opt/baballonia/Modules"  
      cp "${baballonia-uvc-dll}" "$out/opt/baballonia/Modules/Baballonia.LibuvcCapture.dll"  
  
      # Final permissions: readable for everyone  
      chmod -R u+rwX,go+rX "$out"  
    '';  
  
    meta = with lib; {  
      description = "Baballonia with Libuvc module merged into Modules";  
      homepage    = "https://github.com/Project-Babble/Baballonia";  
      license     = licenses.mit;  
      platforms   = [ "x86_64-linux" ];  
    };  
  };  
in  
  
pkgs.buildFHSEnvBubblewrap {  
  name = "baballonia-uvc";  
  
  targetPkgs = pkgs: with pkgs; [  
    glibc  
    stdenv.cc.cc  
    zlib  
    icu  
    openssl  
    libuvc  
    libGL  
    glib  
    libxkbcommon  
    xorg.libX11  
    xorg.libXcursor  
    xorg.libXrandr  
    xorg.libXi  
    xorg.libICE  
    xorg.libSM  
    xorg.libXext  
    fontconfig  
    freetype  
    alsa-lib  
    udev  
    gst_all_1.gstreamer  
    gst_all_1.gst-plugins-base  
    gst_all_1.gst-plugins-good  
  ];  
  
  extraBwrapArgs = [  
    "--bind" "/home/jay" "/home"  
    "--bind" "/home/jay/ProjectBabble" "/home/ProjectBabble"  
  ];  
  
  runScript = "${pkgs.writeShellScriptBin "baballonia-uvc-launch" ''  
    set -eu  
    cd /home  
    exec "${baballonia-with-uvc}/opt/baballonia/Baballonia.Desktop"  
  ''}/bin/baballonia-uvc-launch";  
  
  extraEnv = {  
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "false";  
  };  
  
  meta = with lib; {  
    description = "Baballonia FHS env with Libuvc module included";  
    homepage    = "https://github.com/Project-Babble/Baballonia";  
    license     = licenses.mit;  
    platforms   = [ "x86_64-linux" ];  
  };  
}   

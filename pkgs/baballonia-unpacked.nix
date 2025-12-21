{ stdenvNoCC, fetchurl, lib }:  
  
stdenvNoCC.mkDerivation rec {  
  pname = "baballonia-unpacked";  
  version = "1.1.0.9rc4";  
  
  src = fetchurl {  
    url = "https://github.com/Project-Babble/Baballonia/releases/download/v1.1.0.9rc4/Baballonia.x64.v1.1.0.9rc4.tar.gz";  
    sha256 = "sha256-49UHWe9hP3UvbRx1CWvtPLIVTQL9W8mHcVunUABLK48=";  
  };  
  
  # Important: we handle the archive ourselves in installPhase  
  dontUnpack = true;  
  dontBuild = true;  
  dontFixup = true;  
  
  installPhase = ''  
    runHook preInstall  
  
    mkdir -p "$out/opt/baballonia"  
    # src is the tarball; just extract it directly into the target dir  
    tar -xzf "$src" -C "$out/opt/baballonia"  
  
    runHook postInstall  
  '';  
  
  meta = with lib; {  
    description = "Baballonia VR eye and face tracking (prebuilt Linux, unpacked only)";  
    homepage = "https://github.com/Project-Babble/Baballonia";  
    license = licenses.mit;  
    platforms = [ "x86_64-linux" ];  
  };  
}   

{ lib  
, stdenvNoCC  
, fetchzip  
, makeWrapper  
, wine ? null  
}:  
  
let  
  version = "5.2.3.0";  
  assetName = "VRCFaceTracking_5.2.3.0_x64.zip";  
  
in stdenvNoCC.mkDerivation {  
  pname = "vrcfacetracking";  
  inherit version;  
  
  src = fetchzip {  
    url = "https://github.com/benaclejames/VRCFaceTracking/releases/download/${version}/${assetName}";  
    hash = "sha256-13f4n9grs9dm8k3z8l4p3whz3lrgcm2jii5q1hwkrzdr19154ncx";  
  };  
  
  nativeBuildInputs = [ makeWrapper ];  
  
  installPhase = ''  
    runHook preInstall  
  
    mkdir -p $out/opt/vrcfacetracking  
    cp -r ./* $out/opt/vrcfacetracking  
  
    exe="$out/opt/vrcfacetracking/VRCFaceTracking.exe"  
  
    # Sanity check: make sure the .exe exists  
    if [ ! -f "$exe" ]; then  
      echo "ERROR: Expected $exe not found. Check assetName or ZIP contents." >&2  
      ls -la $out/opt/vrcfacetracking >&2  
      exit 1  
    fi  
  
    # Create wrapper if wine is provided  
    ${lib.optionalString (wine != null) ''  
      mkdir -p $out/bin  
      makeWrapper ${wine}/bin/wine $out/bin/VRCFaceTracking \  
        --set WINEPREFIX "$HOME/.wine-vrcft" \  
        --add-flags "$exe"  
    ''}  
  
    runHook postInstall  
  '';  
  
  meta = with lib; {  
    description = "OSC app to allow VRChat avatars to interact with eye and facial tracking hardware (Windows build via Wine)";  
    homepage = "https://docs.vrcft.io/docs/vrcft-software/vrcft";  
    license = licenses.asl20;  
    platforms = platforms.linux;  
    maintainers = [];  
  };  
}  

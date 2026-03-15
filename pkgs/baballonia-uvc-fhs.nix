{ pkgs, lib, baballonia-unpacked }:

let
  baballonia-uvc-dll = ./Baballonia.LibuvcCapture.dll;

  baballonia-with-uvc = pkgs.stdenv.mkDerivation {
    pname   = "baballonia-with-uvc";
    version = baballonia-unpacked.version or "unknown";

    src      = null;
    dontUnpack = true;

    installPhase = ''
      set -eu

      mkdir -p "$out/opt"
      cp -r "${baballonia-unpacked}/opt/baballonia" "$out/opt/"
      chmod -R u+rwX "$out/opt/baballonia"

      mkdir -p "$out/opt/baballonia/Modules"
      cp "${baballonia-uvc-dll}" "$out/opt/baballonia/Modules/Baballonia.LibuvcCapture.dll"

      chmod -R u+rwX,go+rX "$out"
    '';

    meta = with lib; {
      description = "Baballonia with Libuvc module merged in";
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
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    v4l-utils
    libv4l
  ];

  extraBwrapArgs = [
    "--bind" "/home/jay" "/home"
    "--bind" "/home/jay/ProjectBabble" "/home/ProjectBabble"
    "--bind" "/home/jay/.config/VRCFaceTracking" "/home/jay/.config/VRCFaceTracking"
    "--share-net"
  ];

  runScript = "${pkgs.writeShellScriptBin "baballonia-uvc-launch" ''
    set -eu
    cd /home
    exec "${baballonia-unpacked}/opt/baballonia/Baballonia.Desktop"
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

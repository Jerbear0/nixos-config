{  
  fetchFromGitHub,  
  fetchpatch2,  
  lib,  
  libGL,  
  libxkbcommon,  
  nix-update-script,  
  openxr-loader,  
  pkg-config,  
  rustPlatform,  
  shaderc,  
  vulkan-loader,  
  stdenv,  
  cmake,  
  libX11,  
  xorgproto,  
}:  
  
rustPlatform.buildRustPackage rec {  
  pname = "xrizer-patched";  
  version = "next-0.3";  
  
  src = fetchFromGitHub {
    owner = "ImSapphire";
    repo = "xrizer";
    rev = "a80a2732aa6e259cf072ab24ac56487dd09e9904";
    hash = "sha256-axRGrFImDa3rFHeHA99S4ORsdioqLKuTHfdwLv7yQHM=";
  };

  patches = [ ];

  cargoHash = "sha256-VwfBb/pEaxcPbOzA+naXT28wmyP7UMxH4xoaHCKvlsQ=";  
  
  nativeBuildInputs = [  
    pkg-config  
    rustPlatform.bindgenHook  
    shaderc  
    cmake
  ];  
  
  buildInputs = [  
    libxkbcommon  
    vulkan-loader  
    openxr-loader  
    libX11
    xorgproto
  ];  
  
  postPatch = ""; 
  
  postInstall = ''  
    mkdir -p $out/lib/xrizer/$platformPath  
    ln -s "$out/lib/libxrizer.so" "$out/lib/xrizer/$platformPath/vrclient.so"  
  '';  
  
  platformPath =  
    {  
      "aarch64-linux" = "bin/linuxarm64";  
      "i686-linux"    = "bin";  
      "x86_64-linux"  = "bin/linux64";  
    }."${stdenv.hostPlatform.system}";  
  
  passthru.updateScript = nix-update-script { };  
  
  meta = {  
    description = "XR-ize your favorite OpenVR games (patched, ImSapphire/xrizer next)";  
    homepage    = "https://github.com/ImSapphire/xrizer";  
    license     = lib.licenses.gpl3Only;  
    maintainers = with lib.maintainers; [ Scrumplex ];  
    platforms   = [  
      "x86_64-linux"  
      "i686-linux"  
      "aarch64-linux"  
    ];  
  };  
}

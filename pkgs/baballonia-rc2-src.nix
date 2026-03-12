{ lib
, stdenv
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, mlVersion ? "4"  # "4" or "5"
}:

let
  mlVersionMap = {
    "4" = { ml = "4.0.2"; onnxTransformer = "4.0.2"; onnxRuntime = "1.18.0"; };
    "5" = { ml = "5.0.0"; onnxTransformer = "5.0.0"; onnxRuntime = "1.20.1"; };
  };
  v = mlVersionMap.${mlVersion};
in

buildDotnetModule rec {
  pname = "baballonia-rc2-ml${mlVersion}";
  version = "1.1.1.0rc2";

  src = fetchFromGitHub {
    owner = "Project-Babble";
    repo = "Baballonia";
    rev = "v1.1.1.0rc2";
    hash = "sha256-wmj8Kbl8VlCLX4UCI5StSb/Viswl0rTz+zhY2sxvA/4=";
  };

  projectFile = "Baballonia.Desktop/Baballonia.Desktop.csproj";
  nugetDeps = ./nuget-deps-rc2-ml${mlVersion}.nix;  # step 2: generate this

  dotnet-sdk     = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  prePatch = ''
    for f in $(find . -name "*.csproj"); do
      sed -i \
        -e 's|Include="Microsoft\.ML" Version="[^"]*"|Include="Microsoft.ML" Version="${v.ml}"|g' \
        -e 's|Include="Microsoft\.ML\.OnnxTransformer" Version="[^"]*"|Include="Microsoft.ML.OnnxTransformer" Version="${v.onnxTransformer}"|g' \
        -e 's|Include="Microsoft\.ML\.OnnxRuntime\.Gpu" Version="[^"]*"|Include="Microsoft.ML.OnnxRuntime" Version="${v.onnxRuntime}"|g' \
        -e 's|Include="Microsoft\.ML\.OnnxRuntime" Version="[^"]*"|Include="Microsoft.ML.OnnxRuntime" Version="${v.onnxRuntime}"|g' \
        "$f"
    done
  '';

  executables = [ "Baballonia.Desktop" ];

  meta = with lib; {
    description = "Baballonia RC2 built from source (ML ${mlVersion}, CPU only)";
    homepage    = "https://github.com/Project-Babble/Baballonia";
    license     = licenses.mit;
    platforms   = [ "x86_64-linux" ];
  };
}

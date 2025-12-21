{ config, lib, pkgs, nixalt, unstable, outoftree, inputs, ... }:  
  
{  
  home.file.".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {  
    url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";  
    sha256 = "x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";  
    fetchLFS = true;  
  };  
  
  xdg.configFile."openxr/1/active_runtime.json".source =  
    "${pkgs.monado}/share/openxr/1/openxr_monado.json";  
  
  # Use the patched xrizer: this *must* be a store path, not the package set itself  
  xdg.configFile."openxr/xrizer".source =  
    "${pkgs.xrizer-patched}";  
  
  xdg.configFile."openvr/openvrpaths.vrpath".text = ''  
    {  
      "config": [  
        "${config.xdg.dataHome}/Steam/config"  
      ],  
      "external_drivers": null,  
      "jsonid": "vrpathreg",  
      "log": [  
        "${config.xdg.dataHome}/Steam/logs"  
      ],  
      "runtime": [  
        "${config.xdg.configHome}/openxr/xrizer/lib/xrizer",  
        "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamVR"  
      ],  
      "version": 1  
    }  
  '';  
}  

{ pkgs, hostRole ? "unknown", ... }:  
  
{  
  imports = [  
    ./home/common/hyprland.nix  
  ]   
  # Import the secret git module if it exists  
  ++ (if builtins.pathExists ./secrets/git.nix then [ ./secrets/git.nix ] else [])  
    
  # Host-specific Hyprland  
  ++ (if hostRole == "laptop" then [ ./home/laptop/hyprland.nix ]  
      else if hostRole == "desktop" then [ ./home/desktop/hyprland.nix ]  
      else []);
 
  home.username = "jay";  
  home.homeDirectory = "/home/jay";  
  
  # optional: silence HM version check, since we matched releases already  
  # home.enableNixpkgsReleaseCheck = false;  
  
  ############################  
  # User packages  
  ############################  
  
home.packages = with pkgs; [
    # CLI tools
    eza
    fastfetch
    fzf
    nnn
    ripgrep
    tree

    # Archives
    p7zip
    unzip
    xz
    zip
    zstd

    # Text / data processing
    gawk
    gnused
    jq
    yq-go

    # Networking
    aria2
    dnsutils
    ethtool
    iftop
    ipcalc
    iperf3
    ldns
    mtr
    nmap
    socat

    # System tools / monitoring
    btop
    ethtool
    iotop
    lm_sensors
    lsof
    pciutils
    sysstat
    usbutils

    # Debug / tracing
    strace
    ltrace

    # Misc utilities
    file
    gnupg
    which

    # Nix tools
    nix-output-monitor

    # Productivity / misc
    glow
    hugo
    cowsay

    # Hyprland ecosystem
    alacritty
    brightnessctl
    grimblast
    mako
    playerctl
    swaybg
    swayidle
    swaylock
    waybar
    wofi
  ];
  
  ############################  
  # Waybar  
  ############################  
  
  programs.waybar = {  
    enable = true;  
  
    # If you just want to reuse your existing config file:  
    settings = {  
      # If your waybar config is JSONC, you can keep using the raw file:  
    };  
  
    # Recommended: use xdg.configFile and keep your original layout  
    # (especially if you have multiple files/modules)  
  };  
  
  xdg.configFile."waybar".source = ./configs/waybar;
 
  ############################  
  # Wofi  
  ############################ 

  programs.wofi = {  
    enable = true;  
    # settings = { ... }; # if you want to rewrite config declaratively later  
  };  

  xdg.configFile."wofi".source = ./configs/wofi;    
 
  ############################  
  # Shell configuration  
  ############################  
  
  programs.bash = {  
    enable = true;  
    enableCompletion = true;  
  
    bashrcExtra = ''  
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"  
    '';  
  
    initExtra = ''  
      fastfetch  
    '';  
  
    shellAliases = {  
      lsa = "ls -al";  
    };  
  };  
  
  ############################  
  # Home Manager state version  
  ############################  
  
  home.stateVersion = "25.11";  
}   

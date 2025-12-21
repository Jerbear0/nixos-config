{ pkgs, hostRole ? "unknown", ... }:  
  
{  
  imports = [  
    ./home/common/hyprland.nix  
  ]  
    ++ (if builtins.pathExists /etc/nixos/secrets/git.nix  
        then [ /etc/nixos/secrets/git.nix ]  
        else [])  
    ++ (if hostRole == "laptop" then [ ./home/laptop/hyprland.nix ]  
        else if hostRole == "desktop" then [ ./home/desktop/hyprland.nix ]  
        else []);  
  
  home.username = "jay";  
  home.homeDirectory = "/home/jay";  
  
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
    settings = { };  
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

    # Force Starship to use our Git-tracked config  
    sessionVariables = {  
      STARSHIP_CONFIG = "/etc/nixos/configs/starship.toml";  
    };  
  
    bashrcExtra = ''  
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"  

      # Load NixOS /etc/nixos git-status prompt hook  
      if [ -f /etc/nixos/configs/bash-nixos-git-status.sh ]; then  
        . /etc/nixos/configs/bash-nixos-git-status.sh  
      fi  
    '';   
 
    initExtra = ''  
      fastfetch  
    '';  
  
    shellAliases = {  
      lsa = "ls -al";  
      ns = "/etc/nixos/gitpullpush";  
      rs-laptop = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-laptop --impure";  
      rs-desktop = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-desktop --impure";  
    };  
  };  
  
  ############################  
  # Starship prompt  
  ############################  
   
  programs.starship = {  
    enable = true;  
    enableBashIntegration = true;  
  };  
  
  # Symlink /etc/nixos/configs/starship.toml -> ~/.config/starship.toml  
  home.file.".config/starship.toml".source = /etc/nixos/configs/starship.toml;  
 
  ############################  
  # Auto git pull service  
  ############################  
  
  systemd.user.services."nixos-config-autopull" = {  
    Unit = {  
      Description = "Auto git pull --rebase for /etc/nixos on login";  
      After = [ "network-online.target" "default.target" ];  
    };  
  
    Service = {  
      Type = "oneshot";  
      WorkingDirectory = "/etc/nixos";  
      ExecStart = "${pkgs.git}/bin/git pull --rebase";  
    };  
  
    Install = {  
      WantedBy = [ "default.target" ];  
    };  
  };  
  
  ############################  
  # Home Manager state version  
  ############################  
  
  home.stateVersion = "25.11";  
}  

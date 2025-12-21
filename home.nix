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
    # Raw escape codes for use in 'echo' (functions)  
    RAW_RED=$'\e[31m'  
    RAW_GREEN=$'\e[32m'  
    RAW_RESET=$'\e[0m'  
  
    # Wrapped escape codes for use in PS1 (prompt variable)  
    CLR_GREEN="\[\e[32m\]"  
    CLR_CYAN="\[\e[36m\]"  
    CLR_BLUE="\[\e[34m\]"  
    CLR_MAGENTA="\[\e[35m\]"  
    CLR_YELLOW="\[\e[33m\]"  
    CLR_RESET="\[\e[0m\]"  
  
    # Show /etc/nixos Git status  
    nixos_git_prompt() {  
      if [ -d /etc/nixos/.git ]; then  
        # Use subshell to avoid changing directory of the main shell  
        (  
          cd /etc/nixos || exit  
          if [ -n "$(git status --porcelain 2>/dev/null)" ]; then  
            echo "''${RAW_RED}[nixos:dirty]''${RAW_RESET}"  
          else  
            echo "''${RAW_GREEN}[nixos:clean]''${RAW_RESET}"  
          fi  
        )  
      fi  
    }  
  
    # Two-line prompt:  
    # line 1: user@host:cwd [nixos:state]  
    # line 2: pretty arrow  
    PS1="''${CLR_GREEN}\u''${CLR_RESET}@''${CLR_CYAN}\h''${CLR_RESET}:''${CLR_BLUE}\w''${CLR_RESET} \$(nixos_git_prompt)\n''${CLR_MAGENTA}❯''${CLR_CYAN}❯''${CLR_YELLOW}❯ ''${CLR_RESET}"        
    '';  
  
    shellAliases = {  
      lsa = "ls -al"; 
      ns = "/etc/nixos/gitpullpush";
      rs-laptop = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-laptop --impure";
      rs-desktop ="sudo nixos-rebuild switch --flake /etc/nixos#nixos-desktop --impure";
    };  
  };  
  
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

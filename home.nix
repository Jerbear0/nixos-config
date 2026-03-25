{ pkgs, hostRole ? "unknown", inputs, ... }:   
{  
  imports = [  
    ./home/common/hyprland.nix  
  ]  
    ++ (if builtins.pathExists ./secrets/git.nix  
        then [ ./secrets/git.nix ]  
        else [])  
    ++ (if hostRole == "laptop" then [ ./home/laptop/hyprland.nix ]  
        else if hostRole == "desktop" then [ ./home/desktop/hyprland.nix ]  
        else []);  

  _module.args.inputs = inputs;
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
    quickshell
    swaybg  
    swayidle  
    swaylock   
    wofi 
    wlogout
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli 
  ];   

  ###########################
  # Caelestia
  ##########################

  home.file.".local/state/caelestia/scheme.json".text = builtins.toJSON {
      name = "tokyonight";
      flavour = "medium";
      mode = "dark";
      variant = "tonalspot";
      colours = {
          primary_paletteKeyColor = "82DCCC";
          secondary_paletteKeyColor = "00AA84";
          tertiary_paletteKeyColor = "82DCCC";
          neutral_paletteKeyColor = "111826";
          neutral_variant_paletteKeyColor = "182545";
          background = "111826";
          onBackground = "E5E7EB";
          surface = "182545";
          surfaceDim = "0D1220";
          surfaceBright = "1E2D4A";
          surfaceContainerLowest = "090E1A";
          surfaceContainerLow = "131D30";
          surfaceContainer = "182545";
          surfaceContainerHigh = "1E2D4A";
          surfaceContainerHighest = "243255";
          onSurface = "E5E7EB";
          surfaceVariant = "182545";
          onSurfaceVariant = "8A9AB5";
          inverseSurface = "E5E7EB";
          inverseOnSurface = "111826";
          outline = "4A5568";
          outlineVariant = "2D3748";
          shadow = "000000";
          scrim = "000000";
          surfaceTint = "82DCCC";
          primary = "82DCCC";
          onPrimary = "111826";
          primaryContainer = "007D6F";
          onPrimaryContainer = "82DCCC";
          inversePrimary = "00AA84";
          secondary = "00AA84";
          onSecondary = "111826";
          secondaryContainer = "182545";
          onSecondaryContainer = "00AA84";
          tertiary = "82DCCC";
          onTertiary = "111826";
          tertiaryContainer = "182545";
          onTertiaryContainer = "82DCCC";
          error = "FB958B";
          onError = "111826";
          errorContainer = "4C2020";
          onErrorContainer = "FB958B";
          primaryFixed = "82DCCC";
          primaryFixedDim = "00AA84";
          onPrimaryFixed = "111826";
          onPrimaryFixedVariant = "182545";
          secondaryFixed = "00AA84";
          secondaryFixedDim = "007D6F";
          onSecondaryFixed = "111826";
          onSecondaryFixedVariant = "182545";
          tertiaryFixed = "82DCCC";
          tertiaryFixedDim = "00AA84";
          onTertiaryFixed = "111826";
          onTertiaryFixedVariant = "182545";
          teal = "82DCCC";
          sky = "82DCCC";
          blue = "82DCCC";
          text = "E5E7EB";
          subtext1 = "8A9AB5";
          subtext0 = "6B7A94";
          base = "111826";
          mantle = "0D1220";
          crust = "090E1A";
          success = "00AA84";
          onSuccess = "111826";
          successContainer = "182545";
          onSuccessContainer = "E5E7EB";
          term0 = "111826";
          term1 = "FB958B";
          term2 = "00AA84";
          term3 = "EBCB8B";
          term4 = "82DCCC";
          term5 = "82DCCC";
          term6 = "82DCCC";
          term7 = "E5E7EB";
          term8 = "4A5568";
          term9 = "FB958B";
          term10 = "00AA84";
          term11 = "EBCB8B";
          term12 = "82DCCC";
          term13 = "82DCCC";
          term14 = "82DCCC";
          term15 = "E5E7EB";
      };
  };

  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
      background = {
          enabled = true;
          wallpaperEnabled = false;
      };
      services = {
          weatherLocation = "45.5017,-73.5673";
      };
  };
  
  ############################  
  # Wofi  
  ############################  
  
  programs.wofi = {  
    enable = true;  
    # settings = { ... }; # if you want to rewrite config declaratively later  
  };  
  
  xdg.configFile."wofi".source = ./configs/wofi;  

  ###########################
  # Monado default
  ##########################

  home.sessionVariables = {
    PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
  };
  
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
  
      # Load NixOS /etc/nixos git-status segment (no PROMPT_COMMAND hacks)  
      if [ -f /etc/nixos/configs/bash-nixos-git-status.sh ]; then  
        . /etc/nixos/configs/bash-nixos-git-status.sh  
      fi  
  
      # Initialize Starship manually  
      eval "$(starship init bash)"  
  
      # Compose: NixOS status segment + Starship prompt  
      # This is the ONLY PROMPT_COMMAND we use.  
      PROMPT_COMMAND='PS1="$(nixos_status_segment)$(starship prompt)"'  

      # Ignore dups of commands in history
      HISTCONTROL=ignoredups:erasedups
  
      # Put commands to run on opening terminal down here
      fastfetch  
    '';  
  
    shellAliases = {  
      lsa = "ls -al";  
      ns = "/etc/nixos/gitpullpush";  
      rs-laptop = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-laptop";  
      rs-desktop = "sudo nixos-rebuild switch --flake /etc/nixos#nixos-desktop";  
      openuri = "dbus-monitor --session interface=org.freedesktop.portal.OpenURI";
    };  
  };  
  
  ############################  
  # Starship prompt  
  ############################  
  
  # We initialize Starship ourselves in bashrcExtra, so no automatic integration  
  programs.starship = {  
    enable = true;  
    enableBashIntegration = false;  
  };  
  
  # Symlink /etc/nixos/configs/starship.toml -> ~/.config/starship.toml  
  home.file.".config/starship.toml".source = ./configs/starship.toml; 
 
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

{  
  description = "NixOS config with Home Manager + Hyprland";  
  
inputs = {  
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";  
  nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";  
  home-manager.url = "github:nix-community/home-manager/release-25.11";  
  home-manager.inputs.nixpkgs.follows = "nixpkgs";  
};  
  
outputs = { self, nixpkgs, nixpkgs-xr, home-manager, ... }:  
  let  
    system = "x86_64-linux";  
    lib = nixpkgs.lib;  
  
    # A pkgs instance for building flake-level packages  
    pkgs = import nixpkgs {  
      inherit system;  
      config = {  
        allowUnfree = true;  
        # add any other nixpkgs.config options you want globally  
      };  
    };  
  in { 
    # New: expose discord-music-presence as a flake package  
    packages.${system}.discord-music-presence =  
      import ./pkgs/discord-music-presence.nix { inherit pkgs lib; };  
  
    # Optional convenience:  
    # defaultPackage.${system} = self.packages.${system}.discord-music-presence;  
  
 
    nixosConfigurations = {  
      nixos-desktop = lib.nixosSystem {  
        inherit system;  
  
        specialArgs = {  
          hostRole = "desktop";  
        };  
  
        modules = [  
          ./configuration.nix  
          ./hosts/desktop.nix    

          nixpkgs-xr.nixosModules.nixpkgs-xr  
          home-manager.nixosModules.home-manager  
  
          ({ pkgs, hostRole, ... }: {  
            home-manager.useGlobalPkgs = true;  
            home-manager.useUserPackages = true;  
  
            home-manager.users.jay = { pkgs, ... }:  
              import ./home.nix {  
                inherit pkgs hostRole;  
              };  
          })  
        ];  
      };  
  
      # (same idea if you also want XR on laptop)  
      nixos-laptop = lib.nixosSystem {  
        inherit system;  
        specialArgs = { hostRole = "laptop"; };  
        modules = [  
          ./configuration.nix  
          ./hosts/laptop.nix  

          nixpkgs-xr.nixosModules.nixpkgs-xr  
          home-manager.nixosModules.home-manager  

          ({ pkgs, hostRole, ... }: {  
            home-manager.useGlobalPkgs = true;  
            home-manager.useUserPackages = true;  
            home-manager.users.jay = { pkgs, ... }:  
              import ./home.nix { inherit pkgs hostRole; };  
          })  
        ];  
      };  
    };  
  }; 
}    

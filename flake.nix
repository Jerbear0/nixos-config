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
      pkgs = import nixpkgs {  
        inherit system;  
        config.allowUnfree = true;  
      };  
      pkgs-xr = import nixpkgs-xr {  
        inherit system;  
      };  
    in {  
      nixosConfigurations = {  
        nixos-laptop = lib.nixosSystem {  
          inherit system;  
  
          specialArgs = {  
            hostRole = "laptop";  
            inherit pkgs-xr;  
          };  
  
          modules = [  
            ./configuration.nix  
            ./hosts/laptop.nix  
  
            home-manager.nixosModules.home-manager  
  
            ({ pkgs, hostRole, pkgs-xr, ... }: {  
              home-manager.useGlobalPkgs = true;  
              home-manager.useUserPackages = true;  
  
              home-manager.users.jay = { pkgs, ... }:  
                import ./home.nix {  
                  inherit pkgs hostRole pkgs-xr;  
                };  
            })  
          ];  
        };  
  
        nixos-desktop = lib.nixosSystem {  
          inherit system;  
  
          specialArgs = {  
            hostRole = "desktop";  
            inherit pkgs-xr;  
          };  
  
          modules = [  
            ./configuration.nix  
            ./hosts/desktop.nix  
  
            home-manager.nixosModules.home-manager  
  
            ({ pkgs, hostRole, pkgs-xr, ... }: {  
              home-manager.useGlobalPkgs = true;  
              home-manager.useUserPackages = true;  
  
              home-manager.users.jay = { pkgs, ... }:  
                import ./home.nix {  
                  inherit pkgs hostRole pkgs-xr;  
                };  
            })  
          ];  
        };  
      };  
    };  
}   

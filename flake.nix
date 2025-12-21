{  
  description = "NixOS config with Home Manager + Hyprland";  
  
  inputs = {  
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";  
    home-manager.url = "github:nix-community/home-manager/release-25.11";  
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  
  };  
  
  outputs = { self, nixpkgs, home-manager, ... }:  
    let  
      system = "x86_64-linux";  
      lib = nixpkgs.lib;  
    in {  
      nixosConfigurations = {  
        nixos-laptop = lib.nixosSystem {  
          inherit system;  
  
          # This is where we define the role for this host  
          specialArgs = {  
            hostRole = "laptop";  
          };  
  
          modules = [  
            ./configuration.nix  
            ./hosts/laptop.nix  
  
            home-manager.nixosModules.home-manager  
  
            # Extra NixOS module to wire Home Manager for user jay  
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
  
        # Only keep this if you actually have ./hosts/desktop.nix  
        # Otherwise comment this whole block out for now.  
        nixos-desktop = lib.nixosSystem {  
          inherit system;  
  
          specialArgs = {  
            hostRole = "desktop";  
          };  
  
          modules = [  
            ./configuration.nix  
            ./hosts/desktop.nix  
  
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
      };  
    };  
}  

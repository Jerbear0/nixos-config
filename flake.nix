{
  description = "NixOS config with Home Manager + Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    hyprland.url = "github:hyprwm/Hyprland";
    caelestia-shell.url = "github:caelestia-dots/shell";
    caelestia-shell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-xr, home-manager, nix-citizen, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      caelestia-patched = inputs.caelestia-shell.packages.${system}.with-cli.overrideAttrs (old: {
        patches = (old.patches or []) ++ [ ./pkgs/caelestia-drawers-bottom-layer.patch ];
      });
    in {
      packages.${system} = {
        discord-music-presence = import ./pkgs/discord-music-presence.nix { inherit pkgs lib; };
        baballonia-rc2-ml4 = pkgs.callPackage ./pkgs/baballonia-rc2-src.nix { mlVersion = "4"; };
        baballonia-rc2-ml5 = pkgs.callPackage ./pkgs/baballonia-rc2-src.nix { mlVersion = "5"; };
      };

      nixosConfigurations = {
        nixos-desktop = lib.nixosSystem {
          inherit system;
          specialArgs = {
            hostRole = "desktop";
            inherit inputs;
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
                  inherit pkgs hostRole inputs;
                };
            })
          ];
        };

        nixos-laptop = lib.nixosSystem {
          inherit system;
          specialArgs = { 
            hostRole = "laptop";
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./hosts/laptop.nix
            nixpkgs-xr.nixosModules.nixpkgs-xr
            home-manager.nixosModules.home-manager
            ({ pkgs, hostRole, ... }: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jay = { pkgs, ... }:
                import ./home.nix { inherit pkgs hostRole inputs; };
            })
          ];
        };
      };
    };
} 

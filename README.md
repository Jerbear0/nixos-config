# NixOS Configuration

My personal NixOS configuration using flakes and home-manager for desktop and laptop systems.

## Features

- 🎮 Gaming setup with Steam, VR support (Monado, SteamVR via xrizer)
- 🎨 Hyprland window manager with Waybar
- 🔧 Modular configuration for desktop and laptop
- 📦 Custom packages (Baballonia, VRCFaceTracking, ALCOM)
- 🌐 Automatic git sync helper script (repo owner only)

## System Requirements

- NixOS 25.11 or later
- x86_64-linux architecture
- NVIDIA GPU (both desktop and laptop configs use NVIDIA drivers)
- For laptop: WiFi capability

## Quick Start

### Fresh NixOS Installation

1. **Install NixOS** using the standard installer (create user: `jay`)

2. **Enable Git and Flakes**

   Edit `/etc/nixos/configuration.nix` and add:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   environment.systemPackages = with pkgs; [ git vim ];
   ```
   
   Then rebuild:
   ```bash
   sudo nixos-rebuild switch
   ```

3. **Clone This Repository**

   ```bash
   sudo mv /etc/nixos /etc/nixos.backup
   sudo git clone https://github.com/Jerbear0/nixos-config.git /etc/nixos
   sudo chown -R jay:users /etc/nixos
   ```

4. **Run Setup Script**

   ```bash
   cd /etc/nixos
   chmod +x setup.sh
   ./setup.sh
   ```

## Repository Structure

```
nixos-config/
├── flake.nix              # Main flake configuration
├── configuration.nix      # Shared system configuration
├── home.nix              # Home-manager configuration
├── setup.sh              # Interactive setup helper
├── gitpullpush           # Git sync helper (owner only)
│
├── configs/              # Application configs (waybar, wofi, etc.)
├── home/                 # Home-manager modules (common/desktop/laptop)
├── hosts/                # Host-specific configs + hardware configs
├── modules/              # Custom NixOS modules (VR, face tracking)
├── pkgs/                 # Custom packages + AppImages
└── secrets/              # Secrets (gitignored)
```

## Usage

### Updating Your System

```bash
# For desktop:
rs-desktop

# For laptop:
rs-laptop
```

## Repo Owner: SSH Setup for Push Access

After running `setup.sh`, configure SSH and git to push changes:

1. **Create git.nix (optional - for declarative git config):**
   ```bash
   mkdir -p /etc/nixos/secrets
   cat > /etc/nixos/secrets/git.nix << 'EOF'
   {
     programs.git = {
       enable = true;
       userName = "Your Name";
       userEmail = "your@email.com";
       
       extraConfig = {
         init.defaultBranch = "main";
         pull.rebase = true;
       };
     };
   }
   EOF
   chmod 600 /etc/nixos/secrets/git.nix
   ```
   
   Note: This is optional. Without it, just use `git config` manually.

2. **Generate SSH key:**
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   ```

3. **Copy your public key:**
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

4. **Add to GitHub:**
   - Go to https://github.com/settings/keys
   - Click "New SSH key"
   - Paste the public key and save

5. **Switch repo to SSH:**
   ```bash
   cd /etc/nixos
   git remote set-url origin git@github.com:Jerbear0/nixos-config.git
   ```

6. **Test connection:**
   ```bash
   ssh -T git@github.com
   ```

## Troubleshooting

### Build Errors
- Verify AppImages exist in `pkgs/`
- Check UUIDs in `hosts/drives/*-drives.nix`
- For laptop: ensure `secrets/wifi-laptop.nix` exists

### Can't Push to GitHub
- Complete SSH setup above
- Verify remote: `git remote get-url origin` (should be `git@github.com:...`)

### Missing Directories
Check: `systemctl status systemd-tmpfiles-setup.service`

## Credits

Built with [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), [Hyprland](https://hyprland.org/), and [nixpkgs-xr](https://github.com/nix-community/nixpkgs-xr).

### Custom Packages

- [Baballonia](https://github.com/Project-Babble/Baballonia) - VR eye and face tracking for Bigscreen Beyond
- [VRCFaceTracking](https://github.com/benaclejames/VRCFaceTracking) - Face tracking for VRChat
- [ALCOM](https://github.com/vrc-get/vrc-get) - VRChat package manager
- [discord-music-presence](https://github.com/ungive/discord-music-presence) - Discord Rich Presence for music players

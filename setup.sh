#!/usr/bin/env bash
# NixOS Configuration Setup Helper
# Run this script after cloning the repo to /etc/nixos

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔════════════════════════════════════════════════════════╗"
echo "║   NixOS Configuration Setup Helper                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# ============================================================================
# STEP 1: Determine Host Type
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Host Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

read -p "Is this a (D)esktop or (L)aptop? [D/L]: " host_type
host_type=$(echo "$host_type" | tr '[:lower:]' '[:upper:]')

if [[ "$host_type" == "D" ]]; then
    HOST="desktop"
    CONFIG_NAME="nixos-desktop"
    info "Configuring for Desktop"
elif [[ "$host_type" == "L" ]]; then
    HOST="laptop"
    CONFIG_NAME="nixos-laptop"
    info "Configuring for Laptop"
else
    error "Invalid choice. Exiting."
    exit 1
fi

echo

# ============================================================================
# STEP 2: Hardware Configuration
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Hardware Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

DRIVES_FILE="hosts/drives/${HOST}-drives.nix"
DRIVES_BACKUP="hosts/drives/${HOST}-drives.nix.backup"

# Ensure the drives directory exists
mkdir -p hosts/drives

warn "Your current hardware config will be backed up to: $DRIVES_BACKUP"
echo

read -p "Generate new hardware configuration? [Y/n]: " gen_hw
gen_hw=${gen_hw:-Y}

if [[ "$gen_hw" =~ ^[Yy]$ ]]; then
    info "Generating hardware configuration..."
    
    # Backup existing drives file
    if [ -f "$DRIVES_FILE" ]; then
        cp "$DRIVES_FILE" "$DRIVES_BACKUP"
        success "Backed up existing configuration"
    fi
    
    # Generate new hardware config
    sudo nixos-generate-config --show-hardware-config > /tmp/new-hardware.nix
    
    # Move it to the right place
    sudo mv /tmp/new-hardware.nix "$DRIVES_FILE"
    sudo chown jay:users "$DRIVES_FILE"
    
    success "Hardware configuration generated at: $DRIVES_FILE"
    warn "IMPORTANT: Keep $DRIVES_BACKUP as a backup of the repo's original config"
else
    info "Skipping hardware configuration generation"
    warn "Make sure to manually update UUIDs in $DRIVES_FILE if needed"
fi

echo

# ============================================================================
# STEP 3: WiFi Configuration (Laptop Only)
# ============================================================================

if [[ "$HOST" == "laptop" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 3: WiFi Configuration (Laptop)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    WIFI_FILE="secrets/wifi-laptop.nix"
    
    if [ -f "$WIFI_FILE" ]; then
        info "WiFi configuration already exists: $WIFI_FILE"
        read -p "Overwrite it? [y/N]: " overwrite_wifi
        overwrite_wifi=${overwrite_wifi:-N}
        
        if [[ ! "$overwrite_wifi" =~ ^[Yy]$ ]]; then
            info "Keeping existing WiFi configuration"
            echo
        else
            rm "$WIFI_FILE"
        fi
    fi
    
    if [ ! -f "$WIFI_FILE" ]; then
        info "Creating WiFi configuration..."
        mkdir -p secrets
        
        read -p "Enter your WiFi SSID: " wifi_ssid
        read -sp "Enter your WiFi password: " wifi_pass
        echo
        
        cat > "$WIFI_FILE" << WIFIEOF
{
  networks = {
    "$wifi_ssid" = {
      psk = "$wifi_pass";
    };
    # Add more networks here as needed:
    # "OtherNetwork" = {
    #   psk = "other-password";
    # };
  };
}
WIFIEOF
        
        chmod 600 "$WIFI_FILE"
        success "WiFi configuration created: $WIFI_FILE"
        echo
    fi
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 3: WiFi Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    info "Skipped (Desktop doesn't use WiFi)"
    echo
fi

# ============================================================================
# STEP 4: Verify AppImages
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Verify Required Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

REQUIRED_FILES=(
    "pkgs/VRCFaceTracking.Avalonia.1.1.1.0.AppImage"
    "pkgs/alcom-1.1.5-x86_64.AppImage"
    "pkgs/Baballonia.LibuvcCapture.dll"
)

ALL_PRESENT=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        success "$file exists"
        # Make executable if it's an AppImage
        if [[ "$file" == *.AppImage ]]; then
            chmod +x "$file"
        fi
    else
        error "$file is MISSING"
        ALL_PRESENT=false
    fi
done

echo

if [[ "$ALL_PRESENT" != "true" ]]; then
    warn "Some required files are missing!"
    warn "Make sure they're committed to your git repo"
    warn "If they're too large, you'll need to download them manually"
fi

# ============================================================================
# STEP 5: Ready to Build
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: Ready to Build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

success "Setup complete!"
echo
info "Your configuration: $CONFIG_NAME"
echo
echo "Next steps:"
echo "  1. Review the generated/created files"
echo "  2. Build your system:"
echo "     ${GREEN}sudo nixos-rebuild switch --flake .#$CONFIG_NAME${NC}"
echo "  3. Reboot when ready:"
echo "     ${GREEN}sudo reboot${NC}"
echo
warn "NOTE: No --impure flag needed!"
echo

read -p "Build the system now? [Y/n]: " build_now
build_now=${build_now:-Y}

if [[ "$build_now" =~ ^[Yy]$ ]]; then
    info "Building system configuration..."
    echo
    sudo nixos-rebuild switch --flake ".#$CONFIG_NAME"
    
    echo
    success "Build complete!"
    echo
    read -p "Reboot now? [y/N]: " reboot_now
    reboot_now=${reboot_now:-N}
    
    if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        info "Remember to reboot when ready: sudo reboot"
    fi
else
    info "Build skipped. Run manually when ready:"
    echo "  sudo nixos-rebuild switch --flake .#$CONFIG_NAME"
fi

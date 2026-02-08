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
DRIVES_TEMPLATE="hosts/drives/${HOST}-drives.nix.template"

# Ensure the drives directory exists
mkdir -p hosts/drives

warn "Hardware configuration will be generated for this machine"
if [ -f "$DRIVES_FILE" ]; then
    warn "Existing $DRIVES_FILE will be overwritten (not in git)"
fi
echo

read -p "Generate hardware configuration now? [Y/n]: " gen_hw
gen_hw=${gen_hw:-Y}

if [[ "$gen_hw" =~ ^[Yy]$ ]]; then
    info "Generating hardware configuration..."
    
    # Generate new hardware config
    sudo nixos-generate-config --show-hardware-config > /tmp/new-hardware.nix
    
    # Move it to the right place
    sudo mv /tmp/new-hardware.nix "$DRIVES_FILE"
    sudo chown jay:users "$DRIVES_FILE"
    
    success "Hardware configuration generated at: $DRIVES_FILE"
    info "This file is gitignored - it's specific to this machine"
else
    if [ -f "$DRIVES_TEMPLATE" ]; then
        warn "Using template file. You'll need to update UUIDs manually in $DRIVES_FILE"
        cp "$DRIVES_TEMPLATE" "$DRIVES_FILE"
    else
        error "No hardware config exists and generation was skipped!"
        error "You must either generate it now or manually create $DRIVES_FILE"
        exit 1
    fi
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
    mkdir -p secrets
    
    # Function to parse existing networks from the file
    parse_networks() {
        if [ ! -f "$WIFI_FILE" ]; then
            echo ""
            return
        fi
        # Extract network SSIDs (lines with = {)
        grep -oP '"\K[^"]+(?=" = \{)' "$WIFI_FILE" 2>/dev/null || echo ""
    }
    
    # Function to scan for WiFi networks
    scan_wifi() {
        info "Scanning for WiFi networks..."
        # Create temporary shell with nmcli
        nix-shell -p networkmanager --run "nmcli -t -f SSID dev wifi list" 2>/dev/null | grep -v '^$' | sort -u
    }
    
    # Function to add a network
    add_network() {
        echo
        read -p "Scan for available networks? [Y/n]: " do_scan
        do_scan=${do_scan:-Y}
        
        if [[ "$do_scan" =~ ^[Yy]$ ]]; then
            available_networks=$(scan_wifi)
            if [ -n "$available_networks" ]; then
                echo
                echo "Available networks:"
                echo "$available_networks" | nl
                echo
                read -p "Enter SSID from list (or type manually): " wifi_ssid
            else
                warn "No networks found or scan failed"
                read -p "Enter WiFi SSID manually: " wifi_ssid
            fi
        else
            read -p "Enter WiFi SSID: " wifi_ssid
        fi
        
        read -sp "Enter WiFi password: " wifi_pass
        echo
        
        # If file doesn't exist, create it
        if [ ! -f "$WIFI_FILE" ]; then
            cat > "$WIFI_FILE" << WIFIEOF
{
  networks = {
    "$wifi_ssid" = {
      psk = "$wifi_pass";
    };
  };
}
WIFIEOF
            chmod 600 "$WIFI_FILE"
            success "WiFi configuration created with network: $wifi_ssid"
        else
            # Add to existing file (before the closing braces)
            # Remove last two lines (closing braces), add new network, then add braces back
            head -n -2 "$WIFI_FILE" > "${WIFI_FILE}.tmp"
            cat >> "${WIFI_FILE}.tmp" << WIFIEOF
    "$wifi_ssid" = {
      psk = "$wifi_pass";
    };
  };
}
WIFIEOF
            mv "${WIFI_FILE}.tmp" "$WIFI_FILE"
            chmod 600 "$WIFI_FILE"
            success "Added network: $wifi_ssid"
        fi
    }
    
    # Function to remove a network
    remove_network() {
        local networks=($(parse_networks))
        local num_networks=${#networks[@]}
        
        if [ $num_networks -eq 0 ]; then
            warn "No networks to remove"
            return
        fi
        
        echo
        echo "Current networks:"
        for i in "${!networks[@]}"; do
            echo "$((i+1)). ${networks[$i]}"
        done
        echo
        
        if [ $num_networks -eq 1 ]; then
            read -p "Remove '${networks[0]}'? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm "$WIFI_FILE"
                success "Removed all networks. File deleted."
            else
                info "Keeping network"
            fi
        else
            read -p "Enter number to remove (1-$num_networks) or 0 to cancel: " choice
            if [ "$choice" -gt 0 ] && [ "$choice" -le $num_networks ]; then
                local network_to_remove="${networks[$((choice-1))]}"
                # Remove the network block from the file
                sed -i "/\"$network_to_remove\" = {/,/};/d" "$WIFI_FILE"
                success "Removed network: $network_to_remove"
            else
                info "Cancelled"
            fi
        fi
    }
    
    # Main WiFi configuration logic
    if [ -f "$WIFI_FILE" ]; then
        networks=($(parse_networks))
        echo "Existing WiFi networks:"
        for network in "${networks[@]}"; do
            echo "  - $network"
        done
        echo
        
        while true; do
            read -p "[A]dd network, [R]emove network, or [C]ontinue? [A/R/C]: " wifi_action
            wifi_action=$(echo "$wifi_action" | tr '[:lower:]' '[:upper:]')
            
            case "$wifi_action" in
                A)
                    add_network
                    ;;
                R)
                    remove_network
                    ;;
                C|"")
                    info "Continuing with existing WiFi configuration"
                    break
                    ;;
                *)
                    warn "Invalid choice. Please enter A, R, or C"
                    ;;
            esac
            
            # Re-read networks after modification
            if [ -f "$WIFI_FILE" ]; then
                networks=($(parse_networks))
                if [ ${#networks[@]} -gt 0 ]; then
                    echo
                    echo "Current networks:"
                    for network in "${networks[@]}"; do
                        echo "  - $network"
                    done
                    echo
                fi
            fi
        done
    else
        info "No WiFi configuration found. Let's create one."
        add_network
    fi
    
    echo
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 3: WiFi Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    info "Skipped (Desktop doesn't use WiFi)"
    echo
fi

# ============================================================================
# STEP 4: Verify Required Files
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Verify Required Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

REQUIRED_FILES=(
    "pkgs/VRCFaceTracking.Avalonia.1.1.1.0.AppImage"
    "pkgs/Baballonia.LibuvcCapture.dll"
)

OPTIONAL_FILES=(
    "pkgs/alcom-1.1.5-x86_64.AppImage"
)

ALL_PRESENT=true

info "Checking required files..."
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
info "Checking optional files..."
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        success "$file exists"
        # Make executable if it's an AppImage
        if [[ "$file" == *.AppImage ]]; then
            chmod +x "$file"
        fi
    else
        info "$file not found (optional - download if needed)"
        info "  Download from: https://github.com/vrc-get/vrc-get/releases"
    fi
done

echo

if [[ "$ALL_PRESENT" != "true" ]]; then
    error "Some required files are missing!"
    error "Make sure they're committed to your git repo or download them manually"
    exit 1
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

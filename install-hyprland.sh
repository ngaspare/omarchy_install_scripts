#!/bin/bash
# Set up Hyprland custom configs for Omarchy Quattro

set -e

echo "Setting up Hyprland configs..."

HYPR_CONFIG_DIR="$HOME/.config/hypr"
CUSTOM_CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/hypr-configs"

if [ ! -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "WARNING: Custom hypr configs not found at $CUSTOM_CONFIG_DIR"
    echo "You'll need to manually copy your configs to ~/.config/hypr/"
    exit 1
fi

# Remove redundant .conf files (superseded by .lua in Quattro)
rm -f "$HYPR_CONFIG_DIR/bindings.conf"
rm -f "$HYPR_CONFIG_DIR/input.conf"
rm -f "$HYPR_CONFIG_DIR/looknfeel.conf"
rm -f "$HYPR_CONFIG_DIR/autostart.conf"
rm -f "$HYPR_CONFIG_DIR/monitors.conf"

# Link custom Lua configs
for file in bindings.lua input.lua looknfeel.lua autostart.lua hyprland.lua monitors.lua; do
    if [ -f "$CUSTOM_CONFIG_DIR/$file" ]; then
        ln -sf "$CUSTOM_CONFIG_DIR/$file" "$HYPR_CONFIG_DIR/$file"
        echo "  Linked $file"
    fi
done

# Remove old override mechanism (obsolete in Quattro)
if grep -q "omarchy_install_scripts/hyprland-overrides.conf" "$HYPR_CONFIG_DIR/hyprland.conf" 2>/dev/null; then
    echo "Removing old hyprland-overrides.conf reference from hyprland.conf..."
    sed -i '/omarchy_install_scripts\/hyprland-overrides.conf/d' "$HYPR_CONFIG_DIR/hyprland.conf"
fi
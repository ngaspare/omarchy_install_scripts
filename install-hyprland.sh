#!/bin/bash
# Set up Hyprland custom configs for Omarchy Quattro

set -e

echo "Setting up Hyprland configs..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
CUSTOM_CONFIG_DIR="$SCRIPT_DIR/hypr-configs"

if [ ! -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "WARNING: Custom hypr configs not found at $CUSTOM_CONFIG_DIR"
    echo "You'll need to manually copy your configs to ~/.config/hypr/"
    exit 1
fi

mkdir -p "$HYPR_CONFIG_DIR"

# Remove redundant .conf files (superseded by .lua in Quattro)
rm -f "$HYPR_CONFIG_DIR/bindings.conf"
rm -f "$HYPR_CONFIG_DIR/input.conf"
rm -f "$HYPR_CONFIG_DIR/looknfeel.conf"
rm -f "$HYPR_CONFIG_DIR/autostart.conf"
rm -f "$HYPR_CONFIG_DIR/monitors.conf"

# Link custom Lua configs using absolute targets. This also repairs broken
# links when the repository was moved or cloned to a different path.
for file in bindings.lua input.lua looknfeel.lua autostart.lua hyprland.lua monitors.lua; do
    if [ -f "$CUSTOM_CONFIG_DIR/$file" ]; then
        ln -sfn "$CUSTOM_CONFIG_DIR/$file" "$HYPR_CONFIG_DIR/$file"
        echo "  Linked $file"
    fi
done

# Remove old override mechanisms. Monitor layout is owned by monitors.lua;
# loading another monitor.conf or generated profile can override it.
if [ -f "$HYPR_CONFIG_DIR/hyprland.conf" ]; then
    sed -i \
        -e '\|source[[:space:]]*=.*\.config/hypr/monitors\.conf|d' \
        -e '\|source[[:space:]]*=.*omarchy_install_scripts/hyprland-overrides\.conf|d' \
        -e '\|source[[:space:]]*=.*hyprland-overrides\.conf|d' \
        "$HYPR_CONFIG_DIR/hyprland.conf"
fi

if [ -e "$HYPR_CONFIG_DIR/hyprmoncfg-monitors.lua" ]; then
    mv -f "$HYPR_CONFIG_DIR/hyprmoncfg-monitors.lua" \
        "$HYPR_CONFIG_DIR/hyprmoncfg-monitors.lua.disabled"
    echo "  Disabled generated hyprmoncfg monitor profile"
fi

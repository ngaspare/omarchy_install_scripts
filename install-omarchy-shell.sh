#!/bin/bash
# Link custom Omarchy shell (bar) config and plugins for Omarchy Quattro

set -e

echo "Setting up Omarchy shell config..."

OMARCHY_CONFIG_DIR="$HOME/.config/omarchy"
CUSTOM_CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/omarchy-configs"

if [ ! -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "WARNING: Custom omarchy shell configs not found at $CUSTOM_CONFIG_DIR"
    echo "You'll need to manually copy your configs to ~/.config/omarchy/"
    exit 1
fi

mkdir -p "$OMARCHY_CONFIG_DIR/plugins"

# Link shell.json
if [ -f "$CUSTOM_CONFIG_DIR/shell.json" ]; then
    rm -f "$OMARCHY_CONFIG_DIR/shell.json"
    ln -sf "$CUSTOM_CONFIG_DIR/shell.json" "$OMARCHY_CONFIG_DIR/shell.json"
    echo "  Linked shell.json"
fi

# Link every custom plugin directory
if [ -d "$CUSTOM_CONFIG_DIR/plugins" ]; then
    for plugin_dir in "$CUSTOM_CONFIG_DIR/plugins"/*/; do
        [ -d "$plugin_dir" ] || continue
        plugin_name="$(basename "$plugin_dir")"
        rm -rf "$OMARCHY_CONFIG_DIR/plugins/$plugin_name"
        ln -sf "$plugin_dir" "$OMARCHY_CONFIG_DIR/plugins/$plugin_name"
        echo "  Linked plugin $plugin_name"
    done
fi

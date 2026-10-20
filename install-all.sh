#!/bin/bash
# Omarchy Quattro custom setup script - orchestrates modular install scripts
#
# NEW MACHINE SETUP (run in order):
#   1. Install base Omarchy first (per official docs at https://omarchy.org)
#   2. Make sure an SSH key for GitHub is set up BEFORE running this script,
#      otherwise install-dotfiles.sh (git clone) and install-autocommit.sh
#      (git push) will fail: test with `ssh -T git@github.com`
#   3. Clone this repo: git clone git@github.com:ngaspare/omarchy_install_scripts.git ~/omarchy_install_scripts
#   4. Run this script: ./install-all.sh
#   5. Check monitor layout: hyprctl monitors
#      The known eDP-1 / HDMI-A-1 / DP-1 three-monitor layout is preserved.
#      On a machine with different output names, or with only one monitor,
#      monitors.lua automatically uses Hyprland's preferred mode and layout.
#      Edit monitors.lua only if that machine needs a custom fixed layout.
#   6. Reload Hyprland: SUPER+SHIFT+R (or re-login), and: omarchy restart shell

set -e

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

echo "=== Omarchy Quattro Custom Setup ==="

# 1. Install stow
"$SCRIPT_DIR/install-stow.sh"

# 2. Clone and stow dotfiles (nvim, tmux, bashrc)
"$SCRIPT_DIR/install-dotfiles.sh"

# 3. Set up Hyprland custom configs
"$SCRIPT_DIR/install-hyprland.sh"

# 4. Set up custom Omarchy shell (bar) config and plugins
"$SCRIPT_DIR/install-omarchy-shell.sh"

# 5. Set up daily auto-commit timer (optional, requires SSH key on GitHub)
"$SCRIPT_DIR/install-autocommit.sh"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Reload Hyprland: SUPER+SHIFT+R (or re-login)"
echo "  2. Verify workspaces 11-19 work with SUPER+CTRL+0-8"
echo "  3. Check monitor layout with: hyprctl monitors"
echo ""
echo "Your customizations active:"
echo "  - 20 workspaces (1-10 default, 11-19 on SUPER+CTRL+0-8)"
echo "  - Custom app bindings (Signal, Obsidian, Typora, 1Password, ChatGPT, etc.)"
echo "  - SUPER+SHIFT+Q = close window, SUPER+E = file manager"
echo "  - SUPER+SPACE = Apps menu, SUPER+ALT+SPACE = Omarchy menu"
echo "  - SUPER+F1-F9 = bar panels"
echo "  - US/HR keyboard layouts with Alt+Alt toggle"
echo "  - 3-monitor setup with workspace assignments"

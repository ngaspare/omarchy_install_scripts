#!/bin/bash
# Fix an Omarchy login loop caused by bad/foreign Hyprland monitor config.
# Run from any TTY (Ctrl+Alt+F3), no graphical session needed:
#   chmod +x ~/omarchy_install_scripts/repair-login-loop.sh
#   ~/omarchy_install_scripts/repair-login-loop.sh
#
# What it does:
#   1. Installs the safe idempotent monitors.lua (only configures connected
#      outputs, falls back to auto-layout if none match)
#   2. Comments out monitor/workspace lines in monitors.conf if that file exists
#   3. Disables hyprmoncfgd so it can't overwrite monitor config again
#   4. Neutralizes the monitor= line in hyprland-overrides.conf
# Then: sudo systemctl restart sddm (or reboot)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"

echo "=== Omarchy login-loop repair ==="

# 1. Safe monitors.lua (idempotent: only connected outputs get rules)
if [ -f "$REPO_DIR/hypr-configs/monitors.lua" ]; then
    cp "$REPO_DIR/hypr-configs/monitors.lua" "$HYPR_DIR/monitors.lua"
    echo "  installed safe monitors.lua"
else
    echo "  ERROR: $REPO_DIR/hypr-configs/monitors.lua missing"
    exit 1
fi

# 2. Neutralize legacy .conf monitor definitions (comment everything monitor/workspace related)
if [ -f "$HYPR_DIR/monitors.conf" ]; then
    if ! grep -q '^# REPAIRED-BY-repair-login-loop' "$HYPR_DIR/monitors.conf"; then
        cp "$HYPR_DIR/monitors.conf" "$HYPR_DIR/monitors.conf.bak.$(date +%s)"
        sed -i -e 's/^\([[:space:]]*monitor[[:space:]]*=\)/#\1/' \
               -e 's/^\([[:space:]]*workspace[[:space:]]*=\)/#\1/' \
               -e 's/^\([[:space:]]*monitorv2[[:space:]]*[{]\)/#\1/' \
               -e 's/^\([[:space:]]*output[[:space:]]*=\)/#\1/' \
               -e 's/^\([[:space:]]*position[[:space:]]*=\)/#\1/' \
               -e 's/^\([[:space:]]*mode[[:space:]]*=\)/#\1/' \
               -e 's/^\([[:space:]]*scale[[:space:]]*=\)/#\1/' \
               "$HYPR_DIR/monitors.conf"
        sed -i '1i # REPAIRED-BY-repair-login-loop (all active lines commented, see *.bak.*)' "$HYPR_DIR/monitors.conf"
        echo "  commented out active lines in monitors.conf (backup kept)"
    else
        echo "  monitors.conf already repaired"
    fi
fi

# 3. Stop hyprmoncfg from fighting the config (its profiles may target external monitors)
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user disable --now hyprmoncfgd.service 2>/dev/null \
        && echo "  disabled hyprmoncfgd" \
        || echo "  hyprmoncfgd not present/disabled"
fi

# 4. Neutralize blanket `monitor=,preferred,auto,1.6` override wherever it lives:
#    the repo copy, plus any overrides file sourced by ~/.config/hypr/hyprland.conf
neutralize_overrides() {
    local f="${1/#\~/$HOME}"
    [ -f "$f" ] || return 0
    if grep -q '^monitor=,preferred,auto,1\.6$' "$f"; then
        cp "$f" "$f.bak.$(date +%s)"
        sed -i 's/^monitor=,preferred,auto,1\.6$/# monitor=,preferred,auto,1.6  # disabled by repair-login-loop/' "$f"
        echo "  neutralized blanket monitor= line in $f"
    fi
}
neutralize_overrides "$REPO_DIR/hyprland-overrides.conf"
if [ -f "$HYPR_DIR/hyprland.conf" ]; then
    while IFS= read -r src; do
        neutralize_overrides "$src"
    done < <(sed -n 's/^source[[:space:]]*=[[:space:]]*\(.*overrides[^[:space:]]*\.conf\)/\1/p' "$HYPR_DIR/hyprland.conf")
fi

# 5. Also fix generated hyprmoncfg files if they exist
for f in "$HYPR_DIR/hyprmoncfg-monitors.lua"; do
    if [ -f "$f" ]; then
        mv "$f" "$f.disabled"
        echo "  moved $(basename "$f") -> $(basename "$f").disabled"
    fi
done

echo ""
echo "=== Done ==="
echo "Next: sudo systemctl restart sddm   (or reboot)"
echo "If you still have your 3-monitor setup, plug those monitors in first:"
echo "the safe monitors.lua auto-detects connected outputs, and once the"
echo "monitors are back, re-run ./install-all.sh to restore exact positions."

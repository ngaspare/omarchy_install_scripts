#!/bin/bash
# Install GNU stow (idempotent - safe to run multiple times)

set -e

if command -v stow >/dev/null 2>&1; then
    echo "Stow already installed: $(stow --version | head -n 1)"
    exit 0
fi

echo "Installing stow..."

if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm stow
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y stow
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y stow
elif command -v brew >/dev/null 2>&1; then
    brew install stow
else
    echo "ERROR: No supported package manager found (pacman, apt-get, dnf, brew)."
    echo "Install GNU stow manually, then re-run this script."
    exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
    echo "ERROR: Stow installation failed."
    exit 1
fi

echo "Stow installed: $(stow --version | head -n 1)"

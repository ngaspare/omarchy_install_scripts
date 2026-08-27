#!/bin/bash
# Clone and stow dotfiles-omarchy (nvim, tmux, bashrc)
# Note: waybar removed (not used in Quattro), starship/nvim optional

REPO_URL="https://github.com/ngaspare/dotfiles-omarchy"
REPO_NAME="dotfiles-omarchy"
ORIGINAL_DIR=$(pwd)

cd ~

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' already exists. Pulling latest..."
    cd "$REPO_NAME" && git pull
else
    echo "Cloning dotfiles-omarchy..."
    git clone "$REPO_URL"
fi

# Check if the clone/pull was successful
if [ $? -eq 0 ]; then
    cd "$REPO_NAME"
    echo "Stowing configs..."

    # Backup and stow
    [ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak.$(date +%s)
    stow bashrc

    stow tmux

    # stow nvim     # uncomment if you have nvim config in the repo
    # stow starship # uncomment if you use starship config from repo
else
    echo "Failed to clone the repository."
    cd "$ORIGINAL_DIR"
    exit 1
fi

cd "$ORIGINAL_DIR"
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "Setting up auto-commit for omarchy repos..."

# Switch both repos to SSH so automated push works without password prompts
switch_to_ssh() {
    local repo="$1"
    local ssh_url="$2"
    if [ -d "$repo/.git" ]; then
        git -C "$repo" remote set-url origin "$ssh_url"
        echo "  Switched $repo remote to SSH"
    fi
}

switch_to_ssh "$HOME/omarchy_install_scripts" "git@github.com:ngaspare/omarchy_install_scripts.git"
switch_to_ssh "$HOME/dotfiles-omarchy"        "git@github.com:ngaspare/dotfiles-omarchy.git"

echo ""
echo "  Make sure your SSH key is added to GitHub:"
echo "  https://github.com/settings/keys"
echo "  Your public key: $(cat ~/.ssh/id_rsa.pub 2>/dev/null || echo 'not found')"
echo ""

# Set up systemd user timer
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/omarchy-autocommit.service" << EOF
[Unit]
Description=Auto-commit omarchy config changes

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/check-and-push.sh
EOF

cat > "$SERVICE_DIR/omarchy-autocommit.timer" << EOF
[Unit]
Description=Daily auto-commit of omarchy configs

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now omarchy-autocommit.timer

echo "Auto-commit timer enabled."
echo "Check logs:   tail -f ~/.local/log/omarchy-autocommit.log"
echo "Timer status: systemctl --user status omarchy-autocommit.timer"

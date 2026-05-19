#!/bin/bash

REPOS=(
    "$HOME/omarchy_install_scripts"
    "$HOME/dotfiles-omarchy"
)

LOG_FILE="$HOME/.local/log/omarchy-autocommit.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

for REPO in "${REPOS[@]}"; do
    if [ ! -d "$REPO/.git" ]; then
        log "Skipping $REPO — not a git repo"
        continue
    fi

    cd "$REPO" || continue

    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        log "$REPO — no changes"
        continue
    fi

    git add -A
    git commit -m "auto: $(date '+%Y-%m-%d')"

    if git push; then
        log "$REPO — pushed successfully"
    else
        log "$REPO — push failed (check SSH key is added to GitHub)"
    fi
done

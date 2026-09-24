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

    # Commit any uncommitted changes
    if ! (git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]); then
        git add -A
        git commit -m "auto: $(date '+%Y-%m-%d')"
        log "$REPO — committed changes"
    fi

    # Push if there are unpushed commits
    if [ -n "$(git log @{u}..HEAD 2>/dev/null)" ]; then
        # Right after boot DNS/networking may not be up yet; wait up to ~90s
        for i in $(seq 1 30); do
            getent hosts github.com >/dev/null 2>&1 && break
            sleep 3
        done

        for attempt in 1 2 3; do
            if git push; then
                log "$REPO — pushed successfully"
                break
            fi
            log "$REPO — push failed (attempt $attempt/3, check SSH key or network)"
            sleep 15
        done
    else
        log "$REPO — no changes"
    fi
done

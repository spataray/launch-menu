#!/bin/bash
# sync-docs.sh — Sync HTML docs from youtube/docs to launch-menu repo and push to GitHub
# Runs via cron every 5 minutes

SOURCE_DIR="/home/steven/Documents/projects/youtube/docs"
REPO_DIR="/home/steven/Documents/projects/git/launch-menu"
LOG_FILE="$REPO_DIR/sync-docs.log"

# Files to watch (shared between youtube/docs and launch-menu)
FILES=(
  "bec-pipeline.html"
  "orchestration-diagram.html"
  "gaming-dev-roadmap.html"
)

CHANGED=()

for file in "${FILES[@]}"; do
  src="$SOURCE_DIR/$file"
  dst="$REPO_DIR/$file"

  # Skip if source doesn't exist
  [[ ! -f "$src" ]] && continue

  # If dest doesn't exist or files differ, copy it
  if [[ ! -f "$dst" ]] || ! cmp -s "$src" "$dst"; then
    cp "$src" "$dst"
    CHANGED+=("$file")
  fi
done

# Nothing changed — exit silently
if [[ ${#CHANGED[@]} -eq 0 ]]; then
  exit 0
fi

cd "$REPO_DIR" || exit 1

# Stage only the changed files
git add "${CHANGED[@]}"

# Build commit message
if [[ ${#CHANGED[@]} -eq 1 ]]; then
  MSG="Auto-sync: update ${CHANGED[0]}"
else
  MSG="Auto-sync: update ${CHANGED[*]}"
fi

git commit -m "$MSG"
git push

# Log it
echo "$(date '+%Y-%m-%d %H:%M:%S') — Synced: ${CHANGED[*]}" >> "$LOG_FILE"

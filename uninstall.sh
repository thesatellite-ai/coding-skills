#!/usr/bin/env bash
set -euo pipefail

# Uninstall Claude Code skills
# Usage: ./uninstall.sh [--all | skill-name ...]

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

RED='\033[0;31m'
NC='\033[0m'

uninstall_skill() {
    local name="$1"
    local dst="$SKILLS_DST/$name"

    if [ -d "$dst" ]; then
        rm -rf "$dst"
        echo -e "  ${RED}Removed${NC} $name"
    else
        echo "  $name not installed, skipping"
    fi
}

case "${1:-}" in
    --all)
        echo "Uninstalling all skills from this repo..."
        for dir in "$SKILLS_SRC"/*/; do
            uninstall_skill "$(basename "$dir")"
        done
        ;;
    --help|-h)
        echo "Usage: ./uninstall.sh [--all | skill-name ...]"
        ;;
    "")
        echo "Usage: ./uninstall.sh [--all | skill-name ...]"
        exit 1
        ;;
    *)
        for name in "$@"; do
            uninstall_skill "$name"
        done
        ;;
esac

echo ""
echo "Done! Restart Claude Code to apply changes."

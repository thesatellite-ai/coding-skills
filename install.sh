#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code skills from this repo
# Usage: ./install.sh [--all | --list | --version | skill-name ...]

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

get_skill_version() {
    local skill_dir="$1"
    if [ -f "$skill_dir/VERSION" ]; then
        cat "$skill_dir/VERSION" | tr -d '[:space:]'
    else
        echo "0.0.0"
    fi
}

list_skills() {
    echo "Available skills:"
    echo ""
    for dir in "$SKILLS_SRC"/*/; do
        name=$(basename "$dir")
        ver=$(get_skill_version "$dir")
        desc=$(head -5 "$dir/SKILL.md" | grep "^description:" | sed 's/description: //')
        printf "  ${GREEN}%-20s${NC} v%-8s %s\n" "$name" "$ver" "$desc"
    done
}

show_version() {
    printf "  %-20s %-12s %-12s %s\n" "SKILL" "INSTALLED" "AVAILABLE" "STATUS"
    printf "  %-20s %-12s %-12s %s\n" "-----" "---------" "---------" "------"
    for dir in "$SKILLS_SRC"/*/; do
        name=$(basename "$dir")
        available=$(get_skill_version "$dir")
        installed="—"
        status=""

        if [ -f "$SKILLS_DST/$name/VERSION" ]; then
            installed=$(cat "$SKILLS_DST/$name/VERSION" | tr -d '[:space:]')
            if [ "$installed" = "$available" ]; then
                status="${GREEN}up to date${NC}"
            else
                status="${YELLOW}update available${NC}"
            fi
        else
            status="not installed"
        fi

        printf "  %-20s %-12s %-12s " "$name" "$installed" "$available"
        echo -e "$status"
    done
}

install_skill() {
    local name="$1"
    local src="$SKILLS_SRC/$name"
    local dst="$SKILLS_DST/$name"

    if [ ! -d "$src" ]; then
        echo "Skill '$name' not found in $SKILLS_SRC"
        return 1
    fi

    local new_ver=$(get_skill_version "$src")

    mkdir -p "$SKILLS_DST"

    if [ -d "$dst" ]; then
        local old_ver=$(get_skill_version "$dst")
        rm -rf "$dst"
        echo -e "  ${YELLOW}Updated${NC} $name ($old_ver -> $new_ver)"
    else
        echo -e "  ${GREEN}Installed${NC} $name (v$new_ver)"
    fi

    cp -r "$src" "$dst"
}

install_all() {
    echo "Installing all skills..."
    for dir in "$SKILLS_SRC"/*/; do
        install_skill "$(basename "$dir")"
    done
    echo ""
    echo -e "${GREEN}Done!${NC} Restart Claude Code to pick up new skills."
}

# Parse args
case "${1:-}" in
    --list|-l)
        list_skills
        ;;
    --version|-v)
        show_version
        ;;
    --help|-h)
        echo "Usage: ./install.sh [--all | --list | --version | skill-name ...]"
        echo ""
        echo "Options:"
        echo "  --list, -l       List available skills"
        echo "  --version, -v    Show installed vs available versions"
        echo "  --all            Install all skills (default)"
        echo "  --help, -h       Show this help"
        echo ""
        echo "Examples:"
        echo "  ./install.sh                  Install all skills"
        echo "  ./install.sh feature-plan     Install only feature-plan"
        echo "  ./install.sh -v               Check versions"
        ;;
    --all|"")
        install_all
        ;;
    *)
        echo "Installing selected skills..."
        for name in "$@"; do
            install_skill "$name"
        done
        echo ""
        echo -e "${GREEN}Done!${NC} Restart Claude Code to pick up new skills."
        ;;
esac

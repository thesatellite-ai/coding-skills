#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code skills from this repo
# Usage: ./install.sh [--all | --list | --version | skill-name ...]

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
VERSION_FILE="$REPO_DIR/VERSION"
INSTALLED_VERSION_FILE="$HOME/.claude/.coding-skills-version"
VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

list_skills() {
    echo "Available skills (v$VERSION):"
    for dir in "$SKILLS_SRC"/*/; do
        name=$(basename "$dir")
        desc=$(head -5 "$dir/SKILL.md" | grep "^description:" | sed 's/description: //')
        printf "  ${GREEN}%-20s${NC} %s\n" "$name" "$desc"
    done
}

show_version() {
    echo -e "Repo version:      ${GREEN}$VERSION${NC}"
    if [ -f "$INSTALLED_VERSION_FILE" ]; then
        installed=$(cat "$INSTALLED_VERSION_FILE" | tr -d '[:space:]')
        echo -e "Installed version: ${BLUE}$installed${NC}"
        if [ "$installed" != "$VERSION" ]; then
            echo -e "${YELLOW}Update available!${NC} Run ./install.sh to upgrade."
        else
            echo "Up to date."
        fi
    else
        echo "Installed version: (not installed)"
    fi
}

stamp_version() {
    # Write version to installed marker
    mkdir -p "$(dirname "$INSTALLED_VERSION_FILE")"
    echo "$VERSION" > "$INSTALLED_VERSION_FILE"

    # Also stamp each installed skill with a .version file
    for dir in "$SKILLS_DST"/*/; do
        skill_name=$(basename "$dir")
        # Only stamp skills that came from this repo
        if [ -d "$SKILLS_SRC/$skill_name" ]; then
            echo "$VERSION" > "$dir/.version"
        fi
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

    mkdir -p "$SKILLS_DST"

    # Check existing version
    if [ -d "$dst" ]; then
        old_ver="none"
        if [ -f "$dst/.version" ]; then
            old_ver=$(cat "$dst/.version" | tr -d '[:space:]')
        fi
        rm -rf "$dst"
        echo -e "  ${YELLOW}Updated${NC} $name ($old_ver -> $VERSION)"
    else
        echo -e "  ${GREEN}Installed${NC} $name (v$VERSION)"
    fi

    cp -r "$src" "$dst"
    echo "$VERSION" > "$dst/.version"
}

install_all() {
    echo "Installing all skills (v$VERSION)..."
    for dir in "$SKILLS_SRC"/*/; do
        install_skill "$(basename "$dir")"
    done
    stamp_version
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
        echo "  --version, -v    Show installed vs repo version"
        echo "  --all            Install all skills (default)"
        echo "  --help, -h       Show this help"
        echo ""
        echo "Examples:"
        echo "  ./install.sh                  Install all skills"
        echo "  ./install.sh feature-plan     Install only feature-plan"
        echo "  ./install.sh -v               Check version"
        ;;
    --all|"")
        install_all
        ;;
    *)
        echo "Installing selected skills (v$VERSION)..."
        for name in "$@"; do
            install_skill "$name"
        done
        stamp_version
        echo ""
        echo -e "${GREEN}Done!${NC} Restart Claude Code to pick up new skills."
        ;;
esac

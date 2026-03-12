#!/usr/bin/env bash
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1" >&2; }

INSTALL_DIR="${INSTALL_DIR:-$HOME/bin}"
SCRIPT_NAME="git-worktree-manager"
GITHUB_OWNER="mdaneshjoo"
GITHUB_REPO="git-work-tree-manager"
GITHUB_API="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}"
CONFIG_DIR="$HOME/.config/git-worktree-manager"
VERSION_FILE="$CONFIG_DIR/version"

echo ""
echo -e "${BOLD}git-worktree-manager installer${NC}"
echo ""

# Detect shell
detect_shell() {
    local shell_name
    shell_name="$(basename "${SHELL:-/bin/bash}")"
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash)
            if [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.profile" ;;
    esac
}

SHELL_RC="$(detect_shell)"

# Check dependencies
info "Checking dependencies..."

if ! command -v git &>/dev/null; then
    err "git is required but not installed."
    exit 1
fi
log "git found"

if ! command -v python3 &>/dev/null; then
    err "python3 is required but not installed."
    exit 1
fi
log "python3 found"

# Create install directory
if [[ ! -d "$INSTALL_DIR" ]]; then
    info "Creating $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    log "Created $INSTALL_DIR"
fi

# Resolve the version to install
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_VERSION=""

if [[ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]]; then
    # Installing from a cloned repo — detect version from git tag
    info "Installing from local source..."
    cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    INSTALL_VERSION=$(cd "$SCRIPT_DIR" && git describe --tags --abbrev=0 2>/dev/null || echo "")
else
    # Fetch latest release tag from GitHub
    info "Fetching latest release from GitHub..."
    LATEST_RELEASE=$(
        if command -v curl &>/dev/null; then
            curl -fsSL "${GITHUB_API}/releases/latest" 2>/dev/null
        elif command -v wget &>/dev/null; then
            wget -qO- "${GITHUB_API}/releases/latest" 2>/dev/null
        else
            err "curl or wget is required to download the script."
            exit 1
        fi
    )
    INSTALL_VERSION=$(python3 -c "import json,sys; print(json.loads(sys.stdin.read()).get('tag_name',''))" <<< "$LATEST_RELEASE")

    if [[ -z "$INSTALL_VERSION" ]]; then
        warn "No releases found, falling back to master branch..."
        INSTALL_VERSION="master"
    fi

    DOWNLOAD_URL="https://raw.githubusercontent.com/${GITHUB_OWNER}/${GITHUB_REPO}/${INSTALL_VERSION}/${SCRIPT_NAME}"
    info "Downloading ${SCRIPT_NAME} (${INSTALL_VERSION})..."
    if command -v curl &>/dev/null; then
        curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
    elif command -v wget &>/dev/null; then
        wget -qO "$INSTALL_DIR/$SCRIPT_NAME" "$DOWNLOAD_URL"
    fi
fi

chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
log "Installed to $INSTALL_DIR/$SCRIPT_NAME"

# Add to PATH if needed
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    info "Adding $INSTALL_DIR to PATH in $SHELL_RC..."

    SHELL_NAME="$(basename "${SHELL:-/bin/bash}")"
    if [[ "$SHELL_NAME" == "fish" ]]; then
        echo "" >> "$SHELL_RC"
        echo "fish_add_path $INSTALL_DIR" >> "$SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    fi
    log "Updated $SHELL_RC"
    PATH_UPDATED=true
else
    log "$INSTALL_DIR already in PATH"
    PATH_UPDATED=false
fi

# Create config directory and save installed version
mkdir -p "$CONFIG_DIR"
if [[ -n "$INSTALL_VERSION" ]]; then
    echo "$INSTALL_VERSION" > "$VERSION_FILE"
    log "Installed version: $INSTALL_VERSION"
fi

# Done
echo ""
echo -e "${GREEN}${BOLD}Installation complete!${NC}"
echo ""
echo -e "  Usage:  ${CYAN}git-worktree-manager <branch>${NC}"
echo -e "  List:   ${CYAN}git-worktree-manager -l${NC}"
echo -e "  Remove: ${CYAN}git-worktree-manager -r <id>${NC}"
echo -e "  Help:   ${CYAN}git-worktree-manager -h${NC}"
echo ""

if [[ "$PATH_UPDATED" == "true" ]]; then
    warn "Run this to activate now:"
    echo -e "  ${CYAN}source $SHELL_RC${NC}"
    echo ""
fi

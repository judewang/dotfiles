#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

info()  { echo -e "${GREEN}[✓]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[✗]${RESET} $1"; }

# --- Prerequisites ---

# Check Homebrew
if ! command -v brew &>/dev/null; then
    error "Homebrew not found. Install it first: https://brew.sh"
    exit 1
fi

# Update Neovim
if command -v nvim &>/dev/null; then
    current_ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    info "Neovim found: v${current_ver}"
    warn "Upgrading Neovim to latest..."
    brew upgrade neovim 2>/dev/null || info "Neovim already up to date"
else
    warn "Neovim not found, installing..."
    brew install neovim
fi

# Check Ghostty
if ! command -v ghostty &>/dev/null; then
    warn "Ghostty not installed. Skipping ghostty config."
    SKIP_GHOSTTY=1
fi

# --- Symlink helper ---

link_item() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ -L "$dest" ]; then
        # Already a symlink, update it
        rm "$dest"
    elif [ -e "$dest" ]; then
        # Exists as real file/dir, back it up
        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        warn "${name}: existing config backed up to ${backup}"
        mv "$dest" "$backup"
    fi

    ln -sf "$src" "$dest"
    info "${name}: linked"
}

# --- Create symlinks ---

# Claude statusline
mkdir -p ~/.claude
link_item "${DOTFILES_DIR}/claude/statusline-command.sh" \
          ~/.claude/statusline-command.sh \
          "Claude statusline"

# Neovim
mkdir -p ~/.config
link_item "${DOTFILES_DIR}/nvim" \
          ~/.config/nvim \
          "Neovim"

# Ghostty
if [ -z "$SKIP_GHOSTTY" ]; then
    mkdir -p ~/.config
    link_item "${DOTFILES_DIR}/ghostty" \
              ~/.config/ghostty \
              "Ghostty"
fi

# --- Initialize machine-local files ---

# Ghostty: create config from default if not present
if [ -z "$SKIP_GHOSTTY" ]; then
    ghostty_config="${DOTFILES_DIR}/ghostty/config"
    if [ ! -f "$ghostty_config" ]; then
        cp "${DOTFILES_DIR}/ghostty/config.default" "$ghostty_config"
        info "Ghostty: created config from default template"
    else
        info "Ghostty: config already exists (keeping current)"
    fi
fi

# --- Post-install ---

echo ""
info "Done! Summary:"
echo "  Claude statusline → ~/.claude/statusline-command.sh"
echo "  Neovim            → ~/.config/nvim"
[ -z "$SKIP_GHOSTTY" ] && echo "  Ghostty           → ~/.config/ghostty"
echo ""
info "Open Neovim to auto-install plugins: nvim"

#!/usr/bin/env zsh

# Beebee's dotfiles bootstrap
# Run on a fresh Mac: ./bootstrap.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_DIR="$DOTFILES_DIR/shared"
MACOS_DIR="$DOTFILES_DIR/macos"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo "${BLUE}→ $1${NC}" }
success() { echo "${GREEN}✔ $1${NC}" }
warn()    { echo "${YELLOW}⚠ $1${NC}" }
fail()    { echo "${RED}✘ $1${NC}"; exit 1 }

echo ""
echo "🤖 Beebee dotfiles bootstrap"
echo "============================="
echo ""

#------------------
# Homebrew
#------------------
info "Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
success "Homebrew ready"

#------------------
# Brew bundle
#------------------
info "Installing packages from Brewfile..."
brew bundle --file="$MACOS_DIR/Brewfile"
success "Packages installed"

#------------------
# zplug
#------------------
info "Checking zplug..."
if [ ! -d "$HOME/.zplug" ]; then
    info "Installing zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
success "zplug ready"

#------------------
# Oh My Zsh
#------------------
info "Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
success "Oh My Zsh ready"

#------------------
# Symlinks
#------------------
info "Creating symlinks..."

symlink() {
    local src="$1"
    local dst="$2"
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    success "Linked $dst → $src"
}

symlink "$SHARED_DIR/.zshrc"    "$HOME/.zshrc"
symlink "$SHARED_DIR/.gitconfig" "$HOME/.gitconfig"
symlink "$SHARED_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

#------------------
# macOS defaults
#------------------
echo ""
printf "${YELLOW}Apply macOS system defaults? [y/N]: ${NC}"
if read -q; then
    echo ""
    zsh "$MACOS_DIR/.macos"
else
    echo ""
    warn "Skipped macOS defaults. Run macos/.macos manually to apply."
fi

#------------------
# Git identity
#------------------
info "Configuring git identity..."
git config --global user.name "Beebee"
git config --global user.email "beebee@beebee.bot"
git config --global init.defaultBranch main
success "Git configured"

#------------------
# Set zsh as default shell
#------------------
info "Checking default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi
success "zsh is default shell"

echo ""
echo "🤖 Bootstrap complete! Restart your terminal to apply changes."
echo ""

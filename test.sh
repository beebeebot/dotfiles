#!/usr/bin/env zsh

# Beebee's dotfiles test suite
# Verifies that everything is wired up correctly

PASS=0
FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo "${GREEN}✔${NC} $1"; ((PASS++)) }
fail() { echo "${RED}✘${NC} $1"; ((FAIL++)) }
warn() { echo "${YELLOW}⚠${NC} $1"; ((FAIL++)) }
info() { echo "${BLUE}»${NC} $1" }

echo ""
echo "🤖 Beebee dotfiles test suite"
echo "==============================="
echo ""

#------------------
# Tools
#------------------
info "Checking required tools..."
for cmd in git gh zsh node python3 brew rg; do
    if command -v $cmd &> /dev/null; then
        pass "$cmd: $(command -v $cmd)"
    else
        fail "$cmd: not found"
    fi
done

#------------------
# Symlinks
#------------------
echo ""
info "Checking symlinks..."

check_symlink() {
    local file="$1"
    if [ -L "$file" ]; then
        pass "Symlink: $file → $(readlink $file)"
    elif [ -f "$file" ]; then
        fail "Symlink: $file exists but is NOT a symlink (may not be from dotfiles)"
    else
        fail "Symlink: $file missing"
    fi
}

check_symlink "$HOME/.zshrc"
check_symlink "$HOME/.gitconfig"
check_symlink "$HOME/.p10k.zsh"

#------------------
# Git identity
#------------------
echo ""
info "Checking git identity..."

GIT_NAME=$(git config --global user.name 2>/dev/null)
GIT_EMAIL=$(git config --global user.email 2>/dev/null)
GIT_BRANCH=$(git config --global init.defaultBranch 2>/dev/null)

[[ "$GIT_NAME" == "Beebee" ]] && pass "git user.name: $GIT_NAME" || fail "git user.name: '$GIT_NAME' (expected 'Beebee')"
[[ "$GIT_EMAIL" == "beebee@beebee.bot" ]] && pass "git user.email: $GIT_EMAIL" || fail "git user.email: '$GIT_EMAIL'"
[[ "$GIT_BRANCH" == "main" ]] && pass "git defaultBranch: $GIT_BRANCH" || fail "git defaultBranch: '$GIT_BRANCH' (expected 'main')"

#------------------
# GitHub CLI
#------------------
echo ""
info "Checking GitHub CLI..."

if gh auth status &> /dev/null; then
    GH_USER=$(gh api user --jq '.login' 2>/dev/null)
    [[ "$GH_USER" == "beebeebot" ]] && pass "gh: authenticated as $GH_USER" || fail "gh: authenticated as '$GH_USER' (expected 'beebeebot')"
else
    fail "gh: not authenticated (run: gh auth login)"
fi

#------------------
# Oh My Zsh
#------------------
echo ""
info "Checking Oh My Zsh..."
[ -d "$HOME/.oh-my-zsh" ] && pass "oh-my-zsh installed" || fail "oh-my-zsh not found at ~/.oh-my-zsh"

#------------------
# zplug
#------------------
info "Checking zplug..."
[ -d "$HOME/.zplug" ] && pass "zplug installed" || fail "zplug not found at ~/.zplug"

#------------------
# .zshrc syntax check
#------------------
echo ""
info "Checking .zshrc syntax..."
if zsh -n "$HOME/.zshrc" 2>/dev/null; then
    pass ".zshrc syntax: OK"
else
    fail ".zshrc syntax: errors found (run: zsh -n ~/.zshrc)"
fi

#------------------
# Brewfile check
#------------------
echo ""
info "Checking Brewfile..."
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
if brew bundle check --file="$DOTFILES_DIR/macos/Brewfile" &> /dev/null; then
    pass "Brewfile: all packages installed"
else
    warn "Brewfile: some packages missing (run: brew bundle --file=macos/Brewfile)"
    ((FAIL++))
fi

#------------------
# Summary
#------------------
echo ""
echo "==============================="
TOTAL=$((PASS + FAIL))
if [ $FAIL -eq 0 ]; then
    echo "${GREEN}All $TOTAL checks passed. 🤖${NC}"
else
    echo "${RED}$FAIL/$TOTAL checks failed.${NC}"
    echo "Run ${YELLOW}./bootstrap.sh${NC} to fix missing items."
fi
echo ""

exit $FAIL

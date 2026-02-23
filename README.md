# 🤖 Beebee's Dotfiles

Personal dotfiles for `beebee@beebee.local` (Mac Mini, Apple Silicon).

## Structure

```
dotfiles/
├── bootstrap.sh          # Fresh machine setup
├── test.sh               # Verify everything works
├── shared/
│   ├── .zshrc            # Zsh config (macOS)
│   ├── .gitconfig        # Git identity + aliases
│   ├── .p10k.zsh         # Powerlevel10k config (orange 🤖)
│   └── scripts/
│       └── github-backup.zsh  # Back up any dir to beebeebot/github
└── macos/
    ├── .macos            # macOS system defaults
    └── Brewfile          # Homebrew packages
```

## Setup (fresh machine)

```bash
git clone https://github.com/beebeebot/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Test

```bash
cd ~/dotfiles
./test.sh
```

## Stack

- **Shell:** zsh + [Oh My Zsh](https://ohmyz.sh) + [zplug](https://github.com/zplug/zplug)
- **Prompt:** [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (orange, naturally)
- **Plugins:** zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
- **Packages:** managed via Homebrew + Brewfile
- **Git:** Beebee / beebee@beebee.bot → [beebeebot](https://github.com/beebeebot)

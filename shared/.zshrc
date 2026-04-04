#------------------
# Beebee's .zshrc
# macOS only — this is a Mac Mini, not a server farm
#------------------

#------------------
# Powerlevel10k instant prompt
# Must be FIRST — before any output or sourcing
#------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

SHARED_DIR="$(cd "$(dirname "$(readlink -f "${(%):-%N}")")" && pwd)"
DOTFILES_DIR="$SHARED_DIR/.."
ZPLUG_HOME="$HOME/.zplug"

#------------------
# Shell Variables
#------------------
export CLICOLOR=1
HIST_STAMPS="dd/mm/yyyy"
setopt no_auto_remove_slash

#------------------
# PATH
#------------------
export PATH=$HOME/bin:/usr/local/bin:$PATH

# macOS locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Homebrew (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH=/opt/homebrew/bin:$PATH
export PATH="/usr/local/sbin:$PATH"

# VS Code CLI
if [ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

#------------------
# zplug
#------------------
if [ -d "$ZPLUG_HOME/bin" ]; then
    export PATH="$ZPLUG_HOME/bin:$PATH"
fi

if [ -f $ZPLUG_HOME/init.zsh ]; then
    source $ZPLUG_HOME/init.zsh

    zplug romkatv/powerlevel10k, as:theme, depth:1
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-syntax-highlighting"
    zplug "zsh-users/zsh-history-substring-search"
    zplug "zsh-users/zsh-completions"

    if ! zplug check --verbose; then
        printf "Install zplug plugins? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi

    zplug load
fi

#------------------
# Oh My Zsh
#------------------
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  macos
  node
  python
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source $ZSH/oh-my-zsh.sh
fi

#------------------
# Autocomplete
#------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#------------------
# Tab title
#------------------
autoload -U add-zsh-hook

function tabTitle () {
  window_title="\033]0;${PWD##*/}\007"
  echo -ne "$window_title"
}
add-zsh-hook precmd tabTitle

#------------------
# Aliases
#------------------
alias ls='ls -GFh'
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias rsync='rsync -rhavz --exclude "._*" --exclude ".DS_Store" --partial --progress --stats'

#------------------
# pyenv
#------------------
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

#------------------
# Powerlevel10k config
#------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


#------------------
# Scripts
#------------------
source $SHARED_DIR/scripts/github-backup.zsh

# OpenClaw Completion
source "/Users/beebee/.openclaw/completions/openclaw.zsh"
export PATH=$PATH:$HOME/.maestro/bin
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/beebee/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# TUI wrapped in tmux — survives SSH disconnects from iPad etc.
# Reattaches to existing session or starts fresh
tui() {
  tmux attach -t tui 2>/dev/null || tmux new -s tui 'openclaw tui --session main'
}

# bun completions
[ -s "/Users/beebee/.bun/_bun" ] && source "/Users/beebee/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# age secrets
secret() {
  age -d -i ~/.config/age/keys.txt ~/Dropbox/Droids/secrets/"$1".age
}

secrets() {
  find ~/Dropbox/Droids/secrets -name "*.age" | sed "s|$HOME/Dropbox/Droids/secrets/||;s|\.age$||" | sort
}

secret-add() {
  local recipient=$(age-keygen -y ~/.config/age/keys.txt 2>/dev/null)
  mkdir -p "$(dirname ~/Dropbox/Droids/secrets/"$2".age)"
  echo -n "$1" | age -r "$recipient" -o ~/Dropbox/Droids/secrets/"$2".age
  echo "✅ Saved $2"
}

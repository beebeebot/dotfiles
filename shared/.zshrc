#------------------
# Beebee's .zshrc
# macOS only — this is a Mac Mini, not a server farm
#------------------

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
# Powerlevel10k instant prompt
# Must be near the top — before any output
#------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
# Beebee p10k colour — orange, obviously
#------------------
typeset -g POWERLEVEL9K_DIR_BACKGROUND=#FF5A36
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=#8FF570
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=#E664A6
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=#8FF570
typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=#E664A6
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=#E3E2E8

#------------------
# Scripts
#------------------
source $SHARED_DIR/scripts/github-backup.zsh

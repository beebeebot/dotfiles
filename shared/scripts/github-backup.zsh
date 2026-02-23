#!/usr/bin/env zsh

# GitHub Backup — Beebee edition
# Backs up the current directory to a GitHub repo under beebeebot's account
# Naming convention: beebeebot/{parent}-{project}
# e.g. ~/Developer/hipepipe/backend → beebeebot/hipepipe-backend

github-backup() {
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  echo "${BLUE}GitHub Backup (beebeebot)${NC}"
  echo "========================="
  echo ""

  if ! command -v gh &> /dev/null; then
    echo "${RED}Error: gh CLI not installed. Run: brew install gh${NC}"
    return 1
  fi

  if ! gh auth status &> /dev/null; then
    echo "${RED}Error: gh not authenticated. Run: gh auth login${NC}"
    return 1
  fi

  local sanitize_name() {
    local name="$1"
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    name=$(echo "$name" | sed 's/[^a-z0-9._-]//g')
    echo "$name"
  }

  local current_dir=$(pwd)
  local project_name=$(basename "$current_dir")
  local parent_name=$(basename "$(dirname "$current_dir")")

  project_name=$(sanitize_name "$project_name")
  parent_name=$(sanitize_name "$parent_name")

  if [[ "$parent_name" == "." || "$parent_name" == "$HOME" || "$parent_name" == "beebee" ]]; then
    local repo_name="$project_name"
  else
    local repo_name="${parent_name}-${project_name}"
  fi

  echo "${BLUE}Project:${NC} $current_dir"
  echo "${BLUE}Repo:${NC}    beebeebot/$repo_name"
  echo ""
  printf "${YELLOW}Proceed? [y/N]: ${NC}"
  if ! read -q; then
    echo "\n${YELLOW}Aborted.${NC}"
    return 0
  fi
  echo ""

  if ! git rev-parse --git-dir &> /dev/null; then
    echo "${YELLOW}Initialising git repo...${NC}"
    git init
    git add .
    git commit -m "Initial commit"
  fi

  if ! gh repo view "beebeebot/$repo_name" &> /dev/null; then
    echo "${YELLOW}Creating GitHub repo beebeebot/$repo_name...${NC}"
    gh repo create "beebeebot/$repo_name" --private --source=. --remote=origin --push
    echo "${GREEN}✔ Created and pushed.${NC}"
  else
    echo "${YELLOW}Repo exists, pushing...${NC}"
    git push origin HEAD
    echo "${GREEN}✔ Pushed.${NC}"
  fi
}

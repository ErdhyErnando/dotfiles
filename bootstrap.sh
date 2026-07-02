#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
# One-liner bootstrap for fresh Linux/macOS machines.
# This installs git (if missing), clones the dotfiles repo, and runs setup.
#
# Usage (on a fresh Fedora, for example):
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/bootstrap.sh | bash
#   OR
#   wget -qO- https://raw.githubusercontent.com/ErdhyErnando/dotfiles/main/bootstrap.sh | bash
# ────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/ErdhyErnando/dotfiles.git}"
DOTFILES_DIR="$HOME/dev/dotfiles"

say() { printf "%b\n" "$1"; }

# ── detect OS and install git ──────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v git &>/dev/null; then
    say "Installing git via Xcode CLI tools..."
    xcode-select --install 2>/dev/null || true
  fi
elif [ -f /etc/os-release ]; then
  . /etc/os-release
  if ! command -v git &>/dev/null; then
    case "$ID" in
      ubuntu|debian|linuxmint|pop|elementary|zorin)
        sudo apt-get update -qq && sudo apt-get install -y -qq git ;;
      fedora|rhel|centos|rocky|almalinux)
        sudo dnf install -y git ;;
      arch|endeavouros|manjaro|garuda)
        sudo pacman -S --noconfirm git ;;
      opensuse*)
        sudo zypper install -y git ;;
      *) say "Please install git manually."; exit 1 ;;
    esac
  fi
fi

# ── clone repo and run setup ───────────────────────────────────────

if [ -d "$DOTFILES_DIR" ]; then
  say "dotfiles already cloned at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --rebase
else
  say "Cloning dotfiles..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR"
fi

say "Running setup..."
exec "$DOTFILES_DIR/setup.sh"

#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
NEED_SUDO=""

# ── colors ───────────────────────────────────────────────────
GREEN='\033[0;32m' YELLOW='\033[1;33m' RED='\033[0;31m' CYAN='\033[0;36m'
BOLD='\033[1m'     NC='\033[0m'
say()  { printf "%b\n" "$1"; }
info() { say "${GREEN}[+]${NC} $1"; }
warn() { say "${YELLOW}[!]${NC} $1"; }
err()  { say "${RED}[✗]${NC} $1"; }
step() { say "\n${BOLD}${CYAN}── $1 ──${NC}\n"; }

# ── detect OS / package manager ──────────────────────────────

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian|linuxmint|pop|elementary|zorin) OS="debian" ;;
      fedora|rhel|centos|rocky|almalinux)           OS="fedora" ;;
      arch|endeavouros|manjaro|garuda)              OS="arch" ;;
      opensuse*)                                     OS="suse" ;;
      *) OS="unknown" ;;
    esac
  else
    OS="unknown"
  fi
  info "Detected OS: ${BOLD}$OS${NC}"
}

# ── optionally use sudo ──────────────────────────────────────

maybe_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    "$@"
  fi
}

# ── Phase 1: install packages ────────────────────────────────

install_system_pkgs() {
  step "Installing system packages"

  case "$OS" in
    debian)
      info "Updating apt cache..."
      maybe_sudo apt-get update -qq
      maybe_sudo apt-get install -y -qq git tmux curl unzip ripgrep fd-find
      # Neovim: try PPA first, fall back to apt
      if ! command -v nvim &>/dev/null; then
        if ! dpkg -s software-properties-common &>/dev/null 2>&1; then
          maybe_sudo apt-get install -y -qq software-properties-common
        fi
        maybe_sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
        maybe_sudo apt-get update -qq
        maybe_sudo apt-get install -y -qq neovim || {
          warn "Neovim PPA failed, installing from apt (may be older)..."
          maybe_sudo apt-get install -y -qq neovim
        }
      fi
      # fd-find binary is called fdfind on Debian
      if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        export PATH="$HOME/.local/bin:$PATH"
      fi
      ;;

    fedora)
      maybe_sudo dnf install -y git tmux curl unzip ripgrep fd-find neovim
      ;;

    arch)
      maybe_sudo pacman -S --noconfirm --needed git tmux curl unzip ripgrep fd neovim
      ;;

    suse)
      maybe_sudo zypper install -y git tmux curl unzip ripgrep fd neovim
      ;;

    macos)
      if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install git tmux curl unzip ripgrep fd neovim
      ;;

    *)
      err "Unknown OS. Install these manually: git tmux curl unzip ripgrep fd neovim (>=0.9)"
      read -r -p "Press Enter to continue anyway..." _
      ;;
  esac

  info "All system packages installed."
}

# ── Phase 1b: install Nerd Font (JetBrainsMono) ──────────────

install_nerd_font() {
  step "Installing Nerd Font (JetBrainsMono)"

  local font_dir
  if [[ "$OS" == "macos" ]]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
  fi

  # Check if already installed
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd" || \
     find "$font_dir" -name "JetBrainsMono*Nerd*" 2>/dev/null | grep -q .; then
    info "Nerd Font already installed."
    return
  fi

  info "Downloading JetBrainsMono Nerd Font..."
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  curl -fsSL "$font_url" -o "$tmp_dir/JetBrainsMono.zip"
  mkdir -p "$font_dir"
  unzip -qo "$tmp_dir/JetBrainsMono.zip" -d "$font_dir"
  rm -rf "$tmp_dir"

  if [[ "$OS" != "macos" ]]; then
    fc-cache -fv &>/dev/null || true
  fi

  info "Nerd Font installed. You may need to reconfigure your terminal to use 'JetBrainsMono Nerd Font'."
}

# ── Phase 2: backup existing configs ─────────────────────────

backup_if_exists() {
  local target="$1"
  local label="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
      local link_dest
      link_dest=$(readlink -f "$target" 2>/dev/null || readlink "$target" || true)
      if [ "$link_dest" = "$DOTFILES/$label" ]; then
        info "Already linked: $target → $link_dest"
        return
      fi
    fi
    local backup="${target}.bak.${TIMESTAMP}"
    warn "Backing up: $target → $backup"
    mv "$target" "$backup"
  fi
}

do_backups() {
  step "Backing up existing configs"
  backup_if_exists "$HOME/.tmux.conf"       "tmux/.tmux.conf"
  backup_if_exists "$HOME/.config/nvim"     "nvim"
  backup_if_exists "$HOME/.local/share/nvim" "nvim-data"
  backup_if_exists "$HOME/.local/state/nvim" "nvim-state"
  backup_if_exists "$HOME/.cache/nvim"       "nvim-cache"
}

# ── Phase 3: symlink configs ─────────────────────────────────

symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  info "Linked: $dest → $src"
}

do_symlinks() {
  step "Creating symlinks"
  symlink "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
  symlink "$DOTFILES/nvim"            "$HOME/.config/nvim"
}

# ── Phase 4: TPM + tmux plugins ──────────────────────────────

do_tpm_and_plugins() {
  step "Tmux Plugin Manager + plugins"

  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$tpm_dir" ]; then
    info "Cloning TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    info "TPM already installed."
  fi

  # Auto-install tmux plugins (runs TPM's install_plugins script)
  info "Installing tmux plugins..."
  if [ -f "$tpm_dir/bin/install_plugins" ]; then
    "$tpm_dir/bin/install_plugins" || warn "TPM plugin install had some errors (this is okay)"
  else
    # older TPM uses scripts/install_plugins.sh
    bash "$tpm_dir/scripts/install_plugins.sh" 2>/dev/null || warn "TPM plugin install had some errors (this is okay)"
  fi

  info "Tmux plugins installed."
}

# ── Phase 5: Neovim plugins (headless) ───────────────────────

do_nvim_plugins() {
  step "Installing Neovim plugins (headless)"

  # First launch bootstraps lazy.nvim, second launch syncs all plugins
  info "Bootstrapping Lazy.nvim and installing all plugins..."
  nvim --headless "+Lazy! sync" "+qa" 2>/dev/null || {
    # If Lazy doesn't exist yet, just launching nvim will trigger the bootstrap
    info "Retrying — first launch to bootstrap lazy.nvim..."
    nvim --headless "+qa" 2>/dev/null || true
    nvim --headless "+Lazy! sync" "+qa" 2>/dev/null || true
  }

  info "Neovim plugins installed."
}

# ── Phase 6: health check ────────────────────────────────────

do_healthcheck() {
  step "Running :checkhealth (summary)"
  info "Key checks:"
  nvim --headless "+checkhealth" "+qa" 2>&1 | grep -E '^\s*(ERROR|WARNING|OK)' | head -20 || true
}

# ── Done ─────────────────────────────────────────────────────

print_done() {
  say ""
  say "${BOLD}${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  say "${BOLD}${GREEN}┃  All done — tmux & neovim are ready!              ┃${NC}"
  say "${BOLD}${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  say ""
  say "${BOLD}Next:${NC}"
  say "  ${BOLD}1.${NC} Set your terminal font to: ${BOLD}JetBrainsMono Nerd Font${NC}"
  say "  ${BOLD}2.${NC} Launch tmux and you're good to go."
  say ""
  say "${BOLD}Keybindings:${NC}"
  say "  tmux:  Ctrl+b ${BOLD}h/j/k/l${NC} (vim-style pane nav), ${BOLD}r${NC} (reload), ${BOLD}I${NC} (update plugins)"
  say "  nvim:  ${BOLD}<Space>${NC} leader, ${BOLD}:checkhealth${NC} to verify"
  say ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
  say "${BOLD}${CYAN}"
  say "  ╔══════════════════════════════════════╗"
  say "  ║   dotfiles setup — tmux + neovim     ║"
  say "  ╚══════════════════════════════════════╝"
  say "${NC}"

  detect_os
  install_system_pkgs
  install_nerd_font
  do_backups
  do_symlinks
  do_tpm_and_plugins
  do_nvim_plugins
  do_healthcheck
  print_done
}

main "$@"

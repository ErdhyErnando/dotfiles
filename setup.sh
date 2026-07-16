#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

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

# ── Phase 1: install packages ───────────────────────────────

install_system_pkgs() {
  step "Installing system packages"

  case "$OS" in
    debian)
      info "Updating apt cache..."
      maybe_sudo apt-get update -qq
      maybe_sudo apt-get install -y -qq git curl unzip ripgrep fd-find neovim
      # fd-find binary is called fdfind on Debian
      if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        export PATH="$HOME/.local/bin:$PATH"
      fi
      ;;

    fedora)
      maybe_sudo dnf install -y git curl unzip ripgrep fd-find neovim
      ;;

    arch)
      maybe_sudo pacman -S --noconfirm --needed git curl unzip ripgrep fd neovim
      ;;

    suse)
      maybe_sudo zypper install -y git curl unzip ripgrep fd neovim
      ;;

    macos)
      if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install git curl unzip ripgrep fd neovim
      ;;

    *)
      err "Unknown OS. Install these manually: git curl unzip ripgrep fd neovim (>=0.11)"
      read -r -p "Press Enter to continue anyway..." _
      ;;
  esac

  info "Core system packages installed."
}

# lazygit is optional (used by AstroNvim's toggleterm git UI); best-effort install.
install_lazygit() {
  step "Installing lazygit (optional, for AstroNvim git UI)"
  case "$OS" in
    fedora) maybe_sudo dnf install -y lazygit 2>/dev/null || warn "lazygit not available via dnf; install manually if desired." ;;
    arch)   maybe_sudo pacman -S --noconfirm --needed lazygit 2>/dev/null || warn "lazygit install failed; install manually if desired." ;;
    suse)   maybe_sudo zypper install -y lazygit 2>/dev/null || warn "lazygit install failed; install manually if desired." ;;
    macos)  brew install lazygit 2>/dev/null || warn "lazygit install failed; install manually if desired." ;;
    debian) maybe_sudo apt-get install -y -qq lazygit 2>/dev/null || warn "lazygit not in default apt repos; install manually (https://github.com/jesseduffield/lazygit#installation) if desired." ;;
    *) warn "Install lazygit manually if desired." ;;
  esac
}

# ── verify Neovim >= 0.11 (required by AstroNvim v6) ──────

check_neovim() {
  step "Verifying Neovim version"
  if ! command -v nvim &>/dev/null; then
    err "Neovim not found after install!"
    return
  fi
  local ver
  ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  info "Neovim version: $ver"
  if awk "BEGIN{exit !($ver < 0.11)}"; then
    warn "Neovim $ver is older than 0.11 required by AstroNvim v6. Please upgrade Neovim."
  fi
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
  # NOTE: on this branch the nvim config lives at <repo>/nvim/nvim
  backup_if_exists "$HOME/.config/nvim"     "nvim/nvim"
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
  # This branch keeps the nvim config under <repo>/nvim/nvim
  symlink "$DOTFILES/nvim/nvim" "$HOME/.config/nvim"
}

# ── Phase 4: Neovim plugins (headless) ───────────────────────

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

# ── Phase 5: health check ────────────────────────────────────

do_healthcheck() {
  step "Running :checkhealth (summary)"
  info "Key checks:"
  nvim --headless "+checkhealth" "+qa" 2>&1 | grep -E '^\s*(ERROR|WARNING|OK)' | head -20 || true
}

# ── Done ─────────────────────────────────────────────────────

print_done() {
  say ""
  say "${BOLD}${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  say "${BOLD}${GREEN}┃  All done — AstroNvim (v6) is ready!              ┃${NC}"
  say "${BOLD}${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  say ""
  say "${BOLD}Next:${NC}"
  say "  ${BOLD}1.${NC} Set your terminal font to: ${BOLD}JetBrainsMono Nerd Font${NC}"
  say "  ${BOLD}2.${NC} Launch ${BOLD}nvim${NC} — plugins auto-install on first run"
  say "  ${BOLD}3.${NC} Run ${BOLD}:Copilot setup${NC} once for GitHub auth (uses github/copilot.vim)"
  say "  ${BOLD}4.${NC} Install LSP/parsers on demand: ${BOLD}:LspInstall <server>${NC}, ${BOLD}:TSInstall <lang>${NC}"
  say "  ${BOLD}5.${NC} Update everything later with ${BOLD}:AstroUpdate${NC}"
  say ""
  say "${BOLD}Keybindings:${NC}"
  say "  leader = ${BOLD}<Space>${NC}  •  ${BOLD}jj${NC} → Esc  •  ${BOLD}<C-h/j/k/l>${NC} window nav  •  ${BOLD}<leader>h${NC} clear search"
  say "  ${BOLD}:checkhealth${NC} to verify  •  ${BOLD}:Lazy<CR>${NC} to manage plugins"
  say ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
  say "${BOLD}${CYAN}"
  say "  ╔══════════════════════════════════════╗"
  say "  ║   dotfiles setup — AstroNvim (v6)      ║"
  say "  ╚══════════════════════════════════════╝"
  say "${NC}"

  detect_os
  install_system_pkgs
  install_lazygit
  check_neovim
  install_nerd_font
  do_backups
  do_symlinks
  do_nvim_plugins
  do_healthcheck
  print_done
}

main "$@"

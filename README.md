# dotfiles

Portable, fully-automated Tmux + Neovim (AstroNvim v6) setup.

## One-liner (new machine)

```bash
curl -fsSL https://raw.githubusercontent.com/ErdhyErnando/dotfiles/main/bootstrap.sh | bash
```

This installs everything — system packages, Nerd Font, tmux plugins, neovim plugins — in one shot.

## Manual install

```bash
git clone https://github.com/ErdhyErnando/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./setup.sh
```

## What the script does

1. Detects your OS (Ubuntu/Debian, Fedora, Arch, openSUSE, macOS)
2. Installs system packages: `git tmux curl unzip ripgrep fd neovim`
3. Installs JetBrainsMono Nerd Font (for icons in tmux/nvim)
4. Backs up any existing configs (`.tmux.conf`, `~/.config/nvim`, etc.)
5. Symlinks configs from the repo into place
6. Clones TPM and runs plugin install automatically
7. Bootstraps Lazy.nvim and syncs all 43 neovim plugins (headless)
8. Runs `:checkhealth` to verify

## What's configured

| Tool | Details |
|------|---------|
| **tmux** | TPM + Catppuccin Macchiato theme, vim-style pane nav (`Ctrl+b h/j/k/l`), status bar at top |
| **neovim** | AstroNvim v6 with lazy-lock.json pinning 43 plugins (blink.cmp, snacks, neo-tree, gitsigns, treesitter, dap, etc.) |

## Supported OS

- Fedora / RHEL / CentOS / Rocky / Alma
- Ubuntu / Debian / Mint / Pop!_OS
- Arch / EndeavourOS / Manjaro
- openSUSE
- macOS (Homebrew)

## Post-setup

1. Set your terminal font to **JetBrainsMono Nerd Font**
2. Launch tmux — Catppuccin theme should be active immediately
3. Run `:checkhealth` in nvim if you want to verify everything

## Keybindings

### tmux (`Ctrl+b` prefix)

| Shortcut | Action |
|----------|--------|
| **Pane Management** | |
| `Ctrl+b h` / `j` / `k` / `l` | Navigate panes (vim‑style) |
| `Ctrl+b %` | Split vertically |
| `Ctrl+b "` | Split horizontally |
| `Ctrl+b x` | Kill pane |
| `Ctrl+b z` | Zoom/restore pane |
| `Ctrl+b Space` | Cycle layout |
| **Window Management** | |
| `Ctrl+b c` | New window |
| `Ctrl+b ,` | Rename window |
| `Ctrl+b n` / `p` | Next/previous window |
| `Ctrl+b 0‑9` | Jump to window by number |
| `Ctrl+b &` | Kill window |
| **Session** | |
| `Ctrl+b d` | Detach |
| `Ctrl+b s` | List sessions |
| `Ctrl+b $` | Rename session |
| **Copy / Scroll** | |
| `Ctrl+b [` | Enter copy/scroll mode |
| `Ctrl+b ]` | Paste |
| **Custom** | |
| `Ctrl+b r` | Reload tmux config |
| `Ctrl+b I` | Install/update plugins (TPM) |

### neovim (`<Space>` leader)

| Shortcut | Action |
|----------|--------|
| **Files & Search** | |
| `<Space>ff` | Find files (snacks picker) |
| `<Space>fg` | Live grep |
| `<Space>fw` | Grep word under cursor |
| `<Space>fb` | Find open buffers |
| `<Space>fh` | Find help tags |
| `<Space>fr` | Recent files |
| `<Space>e`  | Toggle neo‑tree file explorer |
| **Buffers & Windows** | |
| `<Space>bn` / `bp` | Next/previous buffer |
| `<Space>bd` | Close buffer (picker) |
| `<Space>wv` | Vertical split |
| `<Space>wh` | Horizontal split |
| `<Space>wd` | Close window |
| **Navigation** | |
| `Ctrl+h` / `j` / `k` / `l` | Move between splits (smart‑splits) |
| `[d` / `]d` | Previous/next diagnostic |
| **Git** | |
| `<Space>gc` | Git commits |
| `<Space>gb` | Git branches |
| `<Space>gl` | Lazygit |
| **LSP (Language Server)** | |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `K`  | Hover documentation |
| `<Space>ca` | Code action |
| `<Space>rn` | Rename symbol |
| `<Space>lf` | Format buffer |
| **Tools** | |
| `<Space>bt` | Toggle terminal (toggleterm) |
| `<Space>cm` | Mason package manager |
| `<Space>uC` | Toggle colorscheme |
| `:Lazy` | Manage plugins |
| `:checkhealth` | Run health checks |

## Structure

```
dotfiles/
├── bootstrap.sh          # One-liner bootstrap (installs git, clones, runs setup)
├── setup.sh              # Main install script (idempotent)
├── README.md
├── tmux/
│   └── .tmux.conf
└── nvim/
    ├── init.lua
    ├── lazy-lock.json
    └── lua/
        ├── lazy_setup.lua
        └── plugins/
            └── ... (plugin overrides)
```

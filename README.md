# dotfiles

Personal configuration files for Neovim and tmux. Inspired by [typecraft](https://www.youtube.com/@typecraft_dev)

## Neovim

Located in `nvim/nvim/` (symlinked to `~/.config/nvim`). Managed with [lazy.nvim](https://github.com/folke/lazy.nvim) which bootstraps automatically on first launch.

### Theme

[gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) with transparent mode enabled. [catppuccin/nvim](https://github.com/catppuccin/nvim) is also included but disabled.

### Plugins

| Plugin                                                                                        | Purpose                                                        |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| [alpha-nvim](https://github.com/goolord/alpha-nvim)                                           | Dashboard landing screen                                       |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs)                                    | Auto-close brackets and quotes                                 |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim)                                      | Toggle comments with `gc`                                      |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                               | Autocompletion engine                                          |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip)                                                | Snippet engine                                                 |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)                          | Pre-built snippets                                             |
| [copilot.vim](https://github.com/github/copilot.vim)                                          | GitHub Copilot integration                                     |
| [conform.nvim](https://github.com/stevearc/conform.nvim)                                      | Format on save (prettierd, stylua, black, isort, clang_format) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap)                                          | Debug adapter protocol (breakpoints, continue)                 |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)                                        | Debugger UI                                                    |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                   | Git decorations, hunk previews, line blame                     |
| [vim-fugitive](https://github.com/tpope/vim-fugitive)                                         | Git commands (`:Git`)                                          |
| [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim)                                     | Formatting and diagnostics via null-ls                         |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint)                                        | Async linting (eslint_d, pylint)                               |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                    | LSP client configuration                                       |
| [mason.nvim](https://github.com/williamboman/mason.nvim)                                      | LSP server installer                                           |
| [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim)                       | Bridge between mason and lspconfig                             |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                                  | Statusline (dracula theme)                                     |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)                               | File explorer sidebar                                          |
| [oil.nvim](https://github.com/stevearc/oil.nvim)                                              | Floating file manager                                          |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)                            | Fuzzy finder                                                   |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                         | Syntax highlighting, text objects, indent                      |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Text object selections, motions, swaps                         |
| [vim-matchup](https://github.com/andymass/vim-matchup)                                        | Enhanced `%` matching                                          |
| [trouble.nvim](https://github.com/folke/trouble.nvim)                                         | Diagnostics list panel                                         |
| [which-key.nvim](https://github.com/folke/which-key.nvim)                                     | Keybinding help popup                                          |

### LSP Servers

| Language                | Server      |
| ----------------------- | ----------- |
| TypeScript / JavaScript | ts_ls       |
| HTML                    | html        |
| Lua                     | lua_ls      |
| Tailwind CSS            | tailwindcss |
| Haskell                 | hls         |
| Python                  | pyright     |
| C / C++                 | clangd      |
| Emmet                   | emmet_ls    |

### Keybindings

#### General

| Key         | Action                 | Mode   |
| ----------- | ---------------------- | ------ |
| `<Space>`   | Leader key             | -      |
| `jj`        | Escape insert mode     | Insert |
| `<C-h>`     | Window left            | Normal |
| `<C-j>`     | Window down            | Normal |
| `<C-k>`     | Window up              | Normal |
| `<C-l>`     | Window right           | Normal |
| `<leader>h` | Clear search highlight | Normal |

#### Telescope

| Key                | Action     |
| ------------------ | ---------- |
| `<C-p>`            | Find files |
| `<leader>fg`       | Live grep  |
| `<leader><leader>` | Old files  |

#### File Explorer (Neo-tree / Oil)

| Key          | Action                      |
| ------------ | --------------------------- |
| `<C-n>`      | Toggle file explorer (left) |
| `<leader>bf` | Buffers in floating window  |
| `-`          | Toggle oil (floating)       |

#### LSP

| Key          | Action                        |
| ------------ | ----------------------------- |
| `K`          | Hover documentation           |
| `<leader>d`  | Open floating diagnostic      |
| `<leader>dl` | Open diagnostic location list |
| `<leader>gd` | Go to definition              |
| `<leader>gr` | Find references               |
| `<leader>ca` | Code action                   |

#### Trouble

| Key          | Action                       |
| ------------ | ---------------------------- |
| `<leader>xx` | Toggle workspace diagnostics |
| `<leader>xX` | Toggle buffer diagnostics    |
| `<leader>cs` | Toggle document symbols      |

#### Git

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>gp` | Preview hunk      |
| `<leader>gt` | Toggle line blame |

#### Formatting

| Key          | Action                               |
| ------------ | ------------------------------------ |
| `<leader>gf` | Format buffer (none-ls)              |
| `<leader>mp` | Format buffer or selection (conform) |

#### Linting

| Key         | Action                           |
| ----------- | -------------------------------- |
| `<leader>l` | Trigger linting for current file |

#### Debug (DAP)

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>dt` | Toggle breakpoint |
| `<leader>dc` | Continue          |

#### Completion (CMP)

| Key         | Action               |
| ----------- | -------------------- |
| `<C-Space>` | Complete             |
| `<C-b>`     | Scroll docs backward |
| `<C-f>`     | Scroll docs forward  |
| `<C-e>`     | Abort completion     |
| `<CR>`      | Confirm selection    |

#### Treesitter Text Objects

| Key                                     | Target                     |
| --------------------------------------- | -------------------------- |
| `af` / `if`                             | Around / inside function   |
| `ac` / `ic`                             | Around / inside class      |
| `a=` / `i=`                             | Around / inside assignment |
| `aB` / `iB`                             | Around / inside block      |
| `at` / `it`                             | Around / inside tag        |
| `a'` / `i'`, `a"` / `i"`, `a\`` / `i\`` | Around / inside string     |
| `ap` / `ip`                             | Around / inside parameter  |

#### Treesitter Motions

| Key         | Target                        |
| ----------- | ----------------------------- |
| `]m` / `]M` | Next function start / end     |
| `[m` / `[M` | Previous function start / end |
| `]]` / `][` | Next class start / end        |
| `[[` / `[]` | Previous class start / end    |

#### Treesitter Parameter Swaps

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>sn` | Swap next parameter     |
| `<leader>sp` | Swap previous parameter |

---

## Tmux

Located in `tmux/.tmux.conf` (symlinked to `~/.tmux.conf`). Uses [TPM](https://github.com/tmux-plugins/tpm) as the plugin manager.

### Theme

[catppuccin/tmux](https://github.com/catppuccin/tmux) (macchiato flavour) with transparent status bar.

### Keybindings

| Key              | Action                           |
| ---------------- | -------------------------------- |
| `prefix r`       | Reload tmux config               |
| `prefix h/j/k/l` | Select pane (left/down/up/right) |
| mouse            | Enabled for all operations       |

### Status Bar

Positioned at the top. Displays:

- Session name (with prefix highlight)
- Current pane command
- Current working directory (truncated)
- Zoom indicator when pane is zoomed
- Date and time
